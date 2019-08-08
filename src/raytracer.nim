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

proc sphereHit(center: Vec3, radius: float32, r: Ray): float =
    let
        oc = r.origin - center
        a = dot(r.direction, r.direction)
        b = 2 * dot(oc, r.direction)
        c = dot(oc, oc) - radius * radius
        disc = b * b - 4 * a * c

    if disc < 0:
        result = -1
        return

    result = (-b - sqrt(disc)) / (2 * a)

const
    backgroundA = Vec3(x: 0.5, y: 0.7, z: 1.0)
    backgroundB = Vec3(x: 1.0, y: 1.0, z: 1.0)

proc color (ray: Ray): Vec3 =

    # sphere
    let
        sphereCenter = Vec3(x: 0, y: 0, z: -1)
        disc = sphereHit(sphereCenter, 0.5, ray)
    if disc > 0:
        let normal = normalize(ray.getPoint(disc) - sphereCenter)
        result = (normal + 1) * 0.5
        return

    # background
    let
        dir = normalize(ray.direction)
        t = 0.5'f32 * (dir.y + 1.0)

    var color = lerp(backgroundA, backgroundB, 1 - t)
    result = color

proc draw(width: int, height: int) =
    var
        imgData   = newSeq[byte](width * height * stbiw.RGB)
        count     = 0

    let
        lowerLeft   = Vec3(x: -2.0, y: -1.0, z: -1.0)
        horizontal  = Vec3(x:  4.0, y:  0.0, z:  0.0)
        vertical    = Vec3(x:  0.0,  y: 2.0, z:  0.0)
        origin      = Vec3(x:  0.0,  y: 0.0, z:  0.0)

    for y in countdown(height - 1, 0):
        for x in 0..<width:

            let
                u = float32(x) / float32(width)
                v = float32(y) / float32(height)
                ray = Ray(origin: origin, direction: lowerLeft + (horizontal * u) + (vertical * v))

            var
                col = color(ray)

            imgData[count    ] = byte(col.x * 255.99)
            imgData[count + 1] = byte(col.y * 255.99)
            imgData[count + 2] = byte(col.z * 255.99)

            count += stbiw.RGB

    stbiw.writePNG("output.png", width, height, stbiw.RGB, imgData)

draw(512, 256)
