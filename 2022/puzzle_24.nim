import std/deques
import std/math
import std/sequtils
import std/sets
import std/strutils
import std/sugar

const
    WALL = '#'
    GROUND = '.'
    BLIZZARD_UP = '^'
    BLIZZARD_DOWN = 'v'
    BLIZZARD_LEFT = '<'
    BLIZZARD_RIGHT = '>'
    WALL_OFFSET = 2

let rawMap = collect:
    for line in stdin.lines:
        line

type
    Coordinate = object
        x, y: int

func `+`(a, b: Coordinate): Coordinate {.inline.} =
    Coordinate(x: a.x + b.x, y: a.y + b.y)

type
    Map = object
        rows: seq[string]
        height: int
        width: int

func idx(n, limit: int): int =
    floorMod((n - 1), (limit - WALL_OFFSET)) + 1

func isAvailable(m: Map, loc: Coordinate, time: int): bool =
    let x = loc.x
    let y = loc.y
    x >= 0 and x < m.height and m.rows[x][y] != WALL and
    m.rows[idx(x + time, m.height)][y] != BLIZZARD_UP and
    m.rows[idx(x - time, m.height)][y] != BLIZZARD_DOWN and
    m.rows[x][idx(y + time, m.width)] != BLIZZARD_LEFT and
    m.rows[x][idx(y - time, m.width)] != BLIZZARD_RIGHT

let height = rawMap.len
let width = rawMap[0].len

let map = Map(
    rows: rawMap,
    height: height,
    width: width,
)

let src = Coordinate(x: 0, y: map.rows[0].find(GROUND))
let dst = Coordinate(x: map.height - 1, y: map.rows[^1].find(GROUND))

type
    State = object
        loc: Coordinate
        time: int

const DIRECTION_STEP = [
    Coordinate(x: 1, y: 0),
    Coordinate(x: 0, y: 1),
    Coordinate(x: -1, y: 0),
    Coordinate(x: 0, y: -1),
    Coordinate(x: 0, y: 0),
]

iterator states(cur: State, m: Map): State =
    let nextTime = cur.time + 1
    for d in DIRECTION_STEP:
        let nextLoc = cur.loc + d
        if m.isAvailable(nextLoc, nextTime):
            yield State(loc: nextLoc, time: nextTime)

func shortestTime(
    m: Map,
    src: Coordinate,
    dst: Coordinate,
    startTime: int = 0
): int =
    let init = State(loc: src, time: startTime)

    var seen = [init].toHashSet
    var q = [init].toDeque
    while q.len != 0:
        let cur = q.popFirst()
        if cur.loc == dst:
            return cur.time

        for next in cur.states(m):
            if not seen.containsOrIncl(next):
                q.addLast(next)

echo "Part 1: ", shortestTime(map, src, dst)
echo "Part 2: ", [
    (src, dst),
    (dst, src),
    (src, dst),
].foldl(shortestTime(map, b[0], b[1], a), 0)
