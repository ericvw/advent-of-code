import std/deques
import std/sequtils
import std/strscans
import std/sugar

type
    Coordinate = tuple
        x, y, z: int

    Matrix3d = seq[seq[seq[int]]]

const LINE_PATTERN = "$i,$i,$i"

let scan: seq[Coordinate] = collect:
    for line in stdin.lines:
        let (success, x, y, z) = line.scanTuple(LINE_PATTERN)
        assert success
        ### XXX: Shift coordinates by 1 to avoid out-of-bounds checks.
        (x + 1, y + 1, z + 1)

let maxX = max(scan.map((c) => c.x))
let maxY = max(scan.map((c) => c.y))
let maxZ = max(scan.map((c) => c.z))

# Generate 3d matrix representation for efficient random access.
# XXX: Pad maximum by 2 to avoid out-of-bounds checks.
var matrix = newSeqWith(maxX + 2, newSeqWith(maxY + 2, newSeq[int](maxZ + 2)))
for c in scan:
    matrix[c.x][c.y][c.z] = 1

iterator neighbors(c: Coordinate): Coordinate =
    let (x, y, z) = c
    yield (x - 1, y, z)
    yield (x + 1, y, z)
    yield (x, y - 1, z)
    yield (x, y + 1, z)
    yield (x, y, z - 1)
    yield (x, y, z + 1)

func cubeExists(m: Matrix3d, c: Coordinate): bool =
    m[c.x][c.y][c.z] == 1

var surfaceArea = 0
for c in scan:
    for n in neighbors(c):
        if not matrix.cubeExists(n):
            inc(surfaceArea)

echo "Part 1: ", surfaceArea

func inBounds(m: Matrix3d, c: Coordinate): bool =
    let (x, y, z) = c
    0 <= x and x < m.len and
    0 <= y and y < m[0].len and
    0 <= z and z < m[0][0].len

# Start with a coordinate on the exterior.
var q: Deque[Coordinate] = [(0, 0, 0)].toDeque
var seen = newSeqWith(maxX + 2, newSeqWith(maxY + 2, newSeq[int](maxZ + 2)))
seen[0][0][0] = 1
var exteriorArea = 0
while q.len != 0:
    let c = q.popFirst()
    if matrix.cubeExists(c):
        # We've hit an exterior cube face from an empty space.
        inc(exteriorArea)
        continue
    for n in neighbors(c):
        if matrix.inBounds(n) and seen[n.x][n.y][n.z] == 0:
            q.addLast(n)
            if not matrix.cubeExists(n):
                # XXX: Allow revisiting cubes from different sides.
                seen[n.x][n.y][n.z] = 1

echo "Part 2: ", exteriorArea
