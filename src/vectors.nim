import interpolation
from math import pow, sqrt

type Vec3* = object
    x*: float32
    y*: float32
    z*: float32

func `+`* (lhs, rhs: Vec3): Vec3 {.inline.} =
    result = Vec3(x: lhs.x + rhs.x,
                  y: lhs.y + rhs.y,
                  z: lhs.z + rhs.z)

func `+`* (lhs: Vec3, rhs: float32): Vec3 {.inline.} =
    result = Vec3(x: lhs.x + rhs,
                  y: lhs.y + rhs,
                  z: lhs.z + rhs)

func `-`* (lhs, rhs: Vec3): Vec3 {.inline.} =
    result = Vec3(x: lhs.x - rhs.x,
                  y: lhs.y - rhs.y,
                  z: lhs.z - rhs.z)

func `+=`* (lhs: ref Vec3, rhs: Vec3) {.inline.} =
    lhs.x += rhs.x
    lhs.y += rhs.y
    lhs.z += rhs.z

func `-=`* (lhs: ref Vec3, rhs: Vec3) {.inline.} =
    lhs.x -= rhs.x
    lhs.y -= rhs.y
    lhs.z -= rhs.z

func `*`* (lhs: Vec3, rhs: float32): Vec3 {.inline.} =
    result = Vec3(x: lhs.x * rhs,
                  y: lhs.y * rhs,
                  z: lhs.z * rhs)

func `*`* (lhs: float32, rhs: Vec3): Vec3 {.inline.} =
    result = Vec3(x: rhs.x * lhs,
                  y: rhs.y * lhs,
                  z: rhs.z * lhs)

func `*=`* (lhs: ref Vec3, rhs: float32) {.inline.} =
    lhs.x *= rhs
    lhs.y *= rhs
    lhs.z *= rhs

func mul* (lhs: ref Vec3, rhs: Vec3): Vec3 {.inline.} =
    result = Vec3(x: lhs.x * rhs.x,
                  y: lhs.y * rhs.y,
                  z: lhs.z * rhs.z)

func `/`* (lhs: Vec3, rhs: Vec3): Vec3 {.inline.} =
    result = Vec3(x: lhs.x / rhs.x,
                  y: lhs.y / rhs.y,
                  z: lhs.z / rhs.z)

func `/`* (lhs: Vec3, rhs: float32): Vec3 {.inline.} =
    result = Vec3(x: lhs.x / rhs,
                  y: lhs.y / rhs,
                  z: lhs.z / rhs)

func dot* (lhs: Vec3, rhs: Vec3): float32 {.inline.} =
    result = lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z;

func len* (v: Vec3): float32 {.inline.} =
    result = sqrt(v.x * v.x + v.y * v.y + v.z * v.z)

func normalize* (v: Vec3): Vec3 {.inline.} =
    result = v / len(v)

func lerp* (a, b: Vec3, t: float32): Vec3 {.inline.} =
    result = Vec3(x: lerp(a.x, b.x, t),
                  y: lerp(a.y, b.y, t),
                  z: lerp(a.z, b.z, t))

