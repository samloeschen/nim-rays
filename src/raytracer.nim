import stb_image/read as stbi
import stb_image/write as stbiw
import interpolation
import vectors
import progress, os

from random import rand
from times import cpuTime
from math import sqrt



type Ray = object
    origin: Vec3
    direction: Vec3

func getPoint(ray: Ray, distance: float32): Vec3 =
    result = ray.origin + (ray.direction * distance)

type HitInfo = object
    t: float32
    position: Vec3
    normal: Vec3

type Plane = object
    position: Vec3
    normal: Vec3

proc hit(p: Plane, r: Ray, tMin: float, tMax: float, hitInfo: var HitInfo): bool =

    let denom = dot(normalize(p.normal), normalize(r.direction))

    if denom > 1e-6:
        let offset = p.position - r.origin
        let t = dot(offset, p.normal) / denom
        if t < tMax and t > tMin:
            hitInfo.t = t
            hitInfo.position = r.getPoint(t)
            hitInfo.normal = p.normal
            return true

    return false

const plane = Plane(position: Vec3(x: 1, y: -0.4, z: -1), normal: Vec3(x: 0, y: -1, z: 0))

type Sphere = object
    center: Vec3
    radius: float32

proc hit(s: Sphere, r: Ray, tMin: float, tMax: float, hitInfo: var HitInfo): bool =
    let
        oc = r.origin - s.center
        a = dot(r.direction, r.direction)
        b = dot(oc, r.direction)
        c = dot(oc, oc) - s.radius * s.radius
        disc = b * b - a * c

    if disc > 0:
        func setHitInfo(t: float, hitInfo: var HitInfo) =
            hitInfo.t = t
            hitInfo.position = r.getPoint(t)
            hitInfo.normal = (hitInfo.position - s.center) / s.radius

        let discRoot = sqrt(disc)
        var t = (-b - discRoot) / a
        if t < tMax and t > tMin:
            setHitInfo(t, hitInfo)
            return true

        t = (-b + discRoot) / a
        if t < tMax and t > tMin:
            setHitInfo(t, hitInfo)
            return true

    return false

proc hit[Surface](sequence: seq[Surface], r: Ray, tMin, tMax: float32, hitInfo: var HitInfo): bool =
    var
        didHit = false
        nearest: float32 = tMax

    # world plane first
    if plane.hit(r, tMin, nearest, hitInfo):
        didHit = true
        nearest = hitInfo.t

    for i in 0..<sequence.len:
        if (sequence[i].hit(r, tMin, nearest, hitInfo)):
            didHit = true
            nearest = hitInfo.t

    return didHit

type Camera = object
    position: Vec3
    lowerLeft: Vec3
    horizontal: Vec3
    vertical: Vec3

func getRay(c: Camera, u, v: float): Ray =
    result = Ray(origin: c.position, direction: c.lowerLeft + (c.horizontal * u) + (c.vertical * v))

# non allocating version of get ray
func setRay(c: Camera, u, v: float, ray: var Ray) =
    ray.origin = c.position
    ray.direction = c.lowerLeft + (c.horizontal * u) + (c.vertical * v)


# SCENE
const
    backgroundA = Vec3(x: 0.5, y: 0.7, z: 1.0)
    backgroundB = Vec3(x: 1.0, y: 1.0, z: 1.0)

const
    spheres = @[
        Sphere(center: Vec3(x: 0, y: 0, z: -1), radius: 0.5),
        Sphere(center: Vec3(x: 1, y: 0, z: -1), radius: 0.4),
        Sphere(center: Vec3(x: -1, y: 0, z: -1), radius: 0.4),
    ]



const camera = Camera(
    lowerLeft:  Vec3(x: -2.0, y: -1.0, z: -1.0),
    horizontal: Vec3(x:  4.0, y:  0.0, z:  0.0),
    vertical:   Vec3(x:  0.0, y:  2.0, z:  0.0),
    position:   Vec3(x:  0.0, y:  0.0, z:  0.0)
)

proc sample (ray: Ray, color: var Vec3, hitInfo: var HitInfo) {.inline} =

    if spheres.hit(ray, 0, 1000, hitInfo):
        color += (hitInfo.normal + 1) * 0.5

    elif plane.hit(ray, 0, 1000, hitInfo):
            color += (hitInfo.normal + 1) * 0.5
    else:
        let
            dir = normalize(ray.direction)
            t = 0.5'f32 * (dir.y + 1.0)
        color += lerp(backgroundA, backgroundB, 1 - t)

proc draw(width, height, samples: int) =

    let
        start = cpuTime()
        increment = int(width * height / 100)

    var bar = newProgressBar()
    bar.start()

    var
        imgData = newSeq[byte](width * height * stbiw.RGB)
        count = 0
        hitInfo = HitInfo()
        ray = Ray()
        w = float32(width)
        h = float32(height)

    for y in countdown(height - 1, 0):
        for x in 0..<width:
            var color = Vec3()
            for s in 0..<samples:
                let
                    u = (float32(x) + rand(1.0)) / w
                    v = (float32(y) + rand(1.0)) / h

                camera.setRay(u, v, ray)
                sample(ray, color, hitInfo)

            color /= float32(samples)

            imgData[count    ] = byte(color.x * 255.99)
            imgData[count + 1] = byte(color.y * 255.99)
            imgData[count + 2] = byte(color.z * 255.99)

            count += stbiw.RGB

            if (count mod increment) == 0:
                bar.increment()

    stbiw.writePNG("output.png", width, height, stbiw.RGB, imgData)

    bar.finish()
    echo "✨ Finished raytracing in ", cpuTime() - start, " seconds ✨"

draw(512, 256, 100)
