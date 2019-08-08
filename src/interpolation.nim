
func saturate* (x: float32): float32 {.inline.} =
    if x < 0: result = 0
    elif x > 1: result = 1

func lerp* (a, b, t: float32): float32 {.inline.} =
    result = a + t * (b - a)

func lerp01* (a, b, t: float32): float32 {.inline.} =
    result = saturate(lerp(a, b, t))
