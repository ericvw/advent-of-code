import std/math
import std/sets
import std/sequtils
import std/strutils
import std/sugar

const
    DOWN = 'D'
    LEFT = 'L'
    RIGHT = 'R'
    UP = 'U'

type
    Motion = tuple[direction: char, steps: int]

let motions: seq[Motion] = collect:
    for line in stdin.lines:
        let motion = line.splitWhitespace()
        (motion[0][0], motion[1].parseInt)

type
    Coordinate = tuple[x, y: int]

    Rope = seq[Coordinate]

proc touching(a, b: Coordinate): bool =
    const MAX_TOUCH_DISTANCE = 1
    return abs(a.x - b.x) <= MAX_TOUCH_DISTANCE and
           abs(a.y - b.y) <= MAX_TOUCH_DISTANCE

proc simulateRope(numKnots: int, motions: seq[Motion]): int =
    var rope: Rope = newSeqWith(numKnots, (0, 0))
    var tailPositions: HashSet[Coordinate] = toHashSet([(0, 0)])

    for m in motions:
        var delta: Coordinate

        case m.direction:
        of DOWN:
            delta = (0, -1)
        of LEFT:
            delta = (-1, 0)
        of RIGHT:
            delta = (1, 0)
        of UP:
            delta = (0, 1)
        else:
            # XXX: All cases should be covered.
            assert false

        for s in 0 ..< m.steps:
            # Move the head knot.
            rope[0].x += delta.x
            rope[0].y += delta.y

            # Move trailing knots.
            for i in 1 ..< rope.len:
                # Bail because remaining knots are touching by transitivity.
                if touching(rope[i], rope[i-1]):
                    break

                # Compute coordinate delta and update trailing knot position.
                rope[i].x += sgn(rope[i-1].x - rope[i].x)
                rope[i].y += sgn(rope[i-1].y - rope[i].y)

            # Capture where the tail has visited.
            tailPositions.incl(rope[^1])

    return tailPositions.len

echo "Part 1: ", simulateRope(2, motions)

echo "Part 2: ", simulateRope(10, motions)
