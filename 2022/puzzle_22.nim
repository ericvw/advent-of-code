import std/math
import std/options
import std/parseutils
import std/sequtils
import std/strutils
import std/sugar
import std/tables

type
    Tile = enum
        Open = "."
        Wall = "#"
        Empty = " "

let grid = collect:
    for line in stdin.lines:
        if line.len == 0:
            break
        line.map((c) => parseEnum[Tile]($c))

type
    TurnDirection = enum
        Clockwise = "R"
        Counterclockwise = "L"

    MoveKind = enum
        Number
        Letter

    Move = object
        case kind: MoveKind
        of Number:
            tiles: int
        of Letter:
            turn: TurnDirection

func parsePath(s: string): seq[Move] =
    var idx = 0
    while true:
        var number: int
        var parsed = parseInt(s, number, idx)
        if parsed == 0:
            break
        result.add(Move(kind: Number, tiles: number))
        inc(idx, parsed)

        if idx == s.len:
            break
        let letter = s[idx]
        result.add(Move(kind: Letter, turn: parseEnum[TurnDirection]($letter)))
        inc(idx)

let path = parsePath(stdin.readLine())

type
    Coordinate = object
        x, y: int

func `+`(a, b: Coordinate): Coordinate =
    Coordinate(x: a.x + b.x, y: a.y + b.y)

type
    Direction = enum
        Right = 0
        Down
        Left
        Up

    Position = object
        loc: Coordinate
        dir: Direction

const
    DIRECTION_STEP: array[Direction, Coordinate] = [
        Coordinate(x: 0, y: 1),
        Coordinate(x: 1, y: 0),
        Coordinate(x: 0, y: -1),
        Coordinate(x: -1, y: 0),
    ]

    DIAGONAL: array[Direction.high.ord + 1, Coordinate] = [
        Coordinate(x: 1, y: 1),
        Coordinate(x: 1, y: -1),
        Coordinate(x: -1, y: -1),
        Coordinate(x: -1, y: 1),
    ]

type
    Map = object
        data: seq[seq[Tile]]
        width: int
        height: int

func isOutside(self: Map, l: Coordinate): bool =
    l.x < 0 or l.x >= self.data.len or l.y < 0 or l.y >= self.data[l.x].len or
    self.data[l.x][l.y] == Tile.Empty

func isInside(self: Map, l: Coordinate): bool =
    not self.isOutside(l)

func get(self: Map, l: Coordinate): Tile =
    if self.isOutside(l):
        Tile.Empty
    else:
        self.data[l.x][l.y]

let map = Map(
    data: grid,
    width: max(grid.map((s) => s.len)),
    height: grid.len,
)

func findStartingCoordinate(m: Map): Coordinate =
    for x, row in m.data:
        for y, c in row:
            if c == Tile.Open:
                return Coordinate(x: x, y: y)

let startPos = findStartingCoordinate(map)

type
    DirAdjacencies = array[Direction, Option[Position]]

    AdjacencyTable = Table[Coordinate, DirAdjacencies]

    AdjacencyMap = object
        map: Map
        adjacencies: AdjacencyTable

func fillBasicAdjacencies(result: var AdjacencyTable, m: Map) =
    for x, row in m.data:
        for y, _ in row:
            let loc = Coordinate(x: x, y: y)

            if m.isOutside(loc):
                continue

            var adjacencies: DirAdjacencies
            for d in Direction:
                let nextLoc = loc + DIRECTION_STEP[d]
                if m.isInside(nextLoc):
                    adjacencies[d] = some(
                        Position(loc: nextLoc, dir: d)
                    )
            result[loc] = adjacencies

func move(m: AdjacencyMap, pos: Position, count: int): Position =
    result = pos
    var lastGoodPos = pos
    var c = count
    while c > 0:
        result = get(m.adjacencies[result.loc][result.dir])

        case m.map.get(result.loc):
        of Tile.Open:
            lastGoodPos = result
            dec(c)
        of Tile.Wall:
            return lastGoodPos
        else:
            discard

func rotate(dir: Direction, turn: TurnDirection, count: int = 1): Direction =
    Direction(
        floorMod(
            (dir.ord + (
                case turn:
                of Clockwise: 1
                of Counterclockwise: -1
            ) * count),
            Direction.high.ord + 1
        )
    )

func followPath(
    map: AdjacencyMap,
    start: Coordinate,
    path: seq[Move],
): Position =
    result.loc = start
    for m in path:
        case m.kind:
        of Number:
            result = map.move(result, m.tiles)
        of Letter:
            result.dir = rotate(result.dir, m.turn)

func finalPassword(p: Position): int =
    1000 * (p.loc.x + 1) + 4 * (p.loc.y + 1) + p.dir.ord

func nextFlatLocation(m: Map, l: Coordinate, d: Direction): Position =
    result.dir = d
    result.loc.x = floorMod(l.x + DIRECTION_STEP[d].x, m.height)
    result.loc.y = floorMod(l.y + DIRECTION_STEP[d].y, m.width)

    while result.loc.y >= m.data[result.loc.x].len or m.isOutside(result.loc):
        result.loc.x = floorMod(result.loc.x + DIRECTION_STEP[d].x, m.height)
        result.loc.y = floorMod(result.loc.y + DIRECTION_STEP[d].y, m.width)

func buildFlatAdjacencies(m: Map): AdjacencyTable =
    fillBasicAdjacencies(result, m)

    for loc, adjacencies in result.mpairs:
        for f, v in adjacencies:
            if isSome(v):
                continue
            adjacencies[f] = some(nextFlatLocation(m, loc, f))

let flatMap = AdjacencyMap(
    map: map,
    adjacencies: buildFlatAdjacencies(map),
)

echo "Part 1: ", finalPassword(followPath(flatMap, startPos, path))

type
    Corner = object
        location: Coordinate
        clockwiseDirection: Direction
        counterClockwiseDirection: Direction

func innerCorners(m: Map): seq[Corner] =
    for x, row in m.data:
        for y, _ in row:
            let loc = Coordinate(x: x, y: y)

            if m.isOutside(loc):
                continue

            for d in Direction:
                let nextLoc = loc + DIRECTION_STEP[d]
                let nextCwDir = rotate(d, Clockwise)
                let nextCwLoc = loc + DIRECTION_STEP[nextCwDir]
                let diagLoc = loc + DIAGONAL[d.ord]
                if m.isInside(nextLoc) and m.isInside(nextCwLoc) and
                   m.isOutside(diagLoc):
                    result.add(
                        Corner(
                            location: loc,
                            clockwiseDirection: nextCwDir,
                            counterClockwiseDirection: d,
                        )
                    )

type
    ZipCursor = object
        zipType: TurnDirection
        loc: Coordinate
        dir: Direction

func perimeterStep(z: ZipCursor, m: Map): ZipCursor =
    result.zipType = z.zipType

    # Get next coordinate along the perimeter.
    let nextLoc = z.loc + DIRECTION_STEP[z.dir]

    if m.isOutside(nextLoc):
        # On a corner. Keep location and update direction.
        result.loc = z.loc
        result.dir = rotate(z.dir, z.zipType)
    else:
        # Advance location and keep direction.
        result.loc = nextLoc
        result.dir = z.dir

func zipFromCorner(
    result: var AdjacencyTable,
    m: Map,
    corner: Corner,
) =
    var cursorCw = ZipCursor(
        zipType: Clockwise,
        loc: corner.location + DIRECTION_STEP[corner.clockwiseDirection],
        dir: corner.clockwiseDirection,
    )

    var cursorCcw = ZipCursor(
        zipType: Counterclockwise,
        loc: corner.location + DIRECTION_STEP[corner.counterClockwiseDirection],
        dir: corner.counterClockwiseDirection,
    )

    var prevDirCw = cursorCw.dir
    var prevDirCcw = cursorCcw.dir

    # Zip until both cursors hit a corner.
    while prevDirCw == cursorCw.dir or prevDirCcw == cursorCcw.dir:
        prevDirCw = cursorCw.dir
        prevDirCcw = cursorCcw.dir

        # Determine exit and enter face directions.
        let exitFaceCw = rotate(cursorCw.dir, Counterclockwise, 1)
        let exitFaceCcw = rotate(cursorCcw.dir, Clockwise, 1)

        let enterFaceCw = rotate(cursorCcw.dir, Counterclockwise, 1)
        let enterFaceCcw = rotate(cursorCw.dir, Clockwise, 1)

        # Create mappings.
        assert isNone(result[cursorCw.loc][exitFaceCw])
        result[cursorCw.loc][exitFaceCw] = some(
            Position(
                loc: cursorCcw.loc,
                dir: enterFaceCw
            )
        )

        assert isNone(result[cursorCcw.loc][exitFaceCcw])
        result[cursorCcw.loc][exitFaceCcw] = some(
            Position(
                loc: cursorCw.loc,
                dir: enterFaceCcw
            )
        )

        # Update cursors.
        cursorCw = perimeterStep(cursorCw, m)
        cursorCcw = perimeterStep(cursorCcw, m)

func buildCubeAdjacencies(m: Map): AdjacencyTable =
    fillBasicAdjacencies(result, m)
    let corners = innerCorners(m)
    for c in corners:
        zipFromCorner(result, m, c)

let cubeMap = AdjacencyMap(
    map: map,
    adjacencies: buildCubeAdjacencies(map)
)
echo "Part 2: ", finalPassword(followPath(cubeMap, startPos, path))
