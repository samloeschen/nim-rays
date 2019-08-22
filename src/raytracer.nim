import stb_image/read as stbi
import stb_image/write as stbiw
import interpolation
import vectors
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

type Sphere = object
    center: Vec3
    radius: float32

func hit(s: Sphere, r: Ray, tMin: float, tMax: float, hitInfo: var HitInfo): bool =
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

func hit[Surface](sequence: seq[Surface], r: Ray, tMin, tMax: float32, hitInfo: var HitInfo): bool =
    var
        didHit = false
        nearest: float32 = tMax

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


# SCENE
const
    backgroundA = Vec3(x: 0.5, y: 0.7, z: 1.0)
    backgroundB = Vec3(x: 1.0, y: 1.0, z: 1.0)

const
    spheres = @[
        Sphere(center: Vec3(x: 0, y: 0, z: -1), radius: 0.5),
        Sphere(center: Vec3(x: 1, y: 0, z: -1), radius: 0.4),
        Sphere(center: Vec3(x: -1, y: 0, z: -1), radius: 0.4)
    ]

const camera = Camera(
    lowerLeft:  Vec3(x: -2.0, y: -1.0, z: -1.0),
    horizontal: Vec3(x:  4.0, y:  0.0, z:  0.0),
    vertical:   Vec3(x:  0.0, y:  2.0, z:  0.0),
    position:   Vec3(x:  0.0, y:  0.0, z:  0.0)
)

# SCENE

func draw(width, height: int) =
    var
        imgData   = newSeq[byte](width * height * stbiw.RGB)
        count     = 0

    for y in countdown(height - 1, 0):
        for x in 0..<width:

            let
                u = float32(x) / float32(width)
                v = float32(y) / float32(height)
                ray = camera.getRay(u, v)

            var col: Vec3

            var hitInfo = HitInfo()

            if spheres.hit(ray, 0, 1000, hitInfo):
                col = (hitInfo.normal + 1) * 0.5
            else:
                let
                    dir = normalize(ray.direction)
                    t = 0.5'f32 * (dir.y + 1.0)
                col = lerp(backgroundA, backgroundB, 1 - t)

            imgData[count    ] = byte(col.x * 255.99)
            imgData[count + 1] = byte(col.y * 255.99)
            imgData[count + 2] = byte(col.z * 255.99)

            count += stbiw.RGB

    stbiw.writePNG("output.png", width, height, stbiw.RGB, imgData)

draw(512, 256)
