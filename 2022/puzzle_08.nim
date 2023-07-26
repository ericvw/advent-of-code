import std/sequtils
import std/sugar

type
    TreeHeight = int
    TreeRow = seq[TreeHeight]
    TreeMap = seq[TreeRow]

let treeMap: TreeMap = collect:
    for line in stdin.lines:
        line.map((h) => h.ord - '0'.ord)

let
    rows = treeMap.len
    cols = treeMap[0].len

proc isEdge(x, y: int): bool =
    x - 1 < 0 or x + 1 >= rows or
    y - 1 < 0 or y + 1 >= cols

proc visibleFromEdge(tm: TreeMap, x, y: int): bool =
    proc isVisible(tm: TreeMap, h, x, y, xStep = 0, yStep = 0): bool =
        if isEdge(x, y):
            return true
        elif h - treeMap[x + xStep][y + yStep] > 0:
            return isVisible(tm, h, x + xStep, y + yStep, xStep, yStep)
        else:
            return false

    let h = tm[x][y]
    return isVisible(tm, h, x, y, xStep = 1) or
           isVisible(tm, h, x, y, xStep = -1) or
           isVisible(tm, h, x, y, yStep = 1) or
           isVisible(tm, h, x, y, yStep = -1)

var nVisibile = 0
for r in 0 ..< rows:
    for c in 0 ..< cols:
        if visibleFromEdge(treeMap, r, c):
            inc(nVisibile)

echo "Part 1: ", nVisibile

proc scenicScore(tm: TreeMap, x, y: int): int =
    proc viewDistance(tm: TreeMap, h, x, y, xStep = 0, yStep = 0): int =
        if isEdge(x, y):
            return 0
        elif h - treeMap[x + xStep][y + yStep] > 0:
            return 1 + viewDistance(tm, h, x + xStep, y + yStep, xStep, yStep)
        else:
            return 1

    let h = tm[x][y]
    return viewDistance(tm, h, x, y, xStep = 1) *
           viewDistance(tm, h, x, y, xStep = -1) *
           viewDistance(tm, h, x, y, yStep = 1) *
           viewDistance(tm, h, x, y, yStep = -1)

var maxScenicScore = 0
for r in 0 ..< rows:
    for c in 0 ..< cols:
        maxScenicScore = max(scenicScore(treeMap, r, c), maxScenicScore)

echo "Part 2: ", maxScenicScore
