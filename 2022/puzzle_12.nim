import std/heapqueue
import std/sequtils
import std/sugar
import std/tables

type HeightMap = seq[string]

let heightmap: HeightMap = collect:
    for line in stdin.lines:
        line

type
    Coordinate = tuple[x: int, y: int]

const
    BEST_SIGNAL_LOCATION = 'E'
    CURENT_POSITION = 'S'
    LOWEST_ELEVATION = 'a'
    HIGHEST_ELEVATION = 'z'

func currentPositionAndBestSignalLocation(m: HeightMap): (Coordinate, Coordinate) =
    var
        currentPosition: Coordinate
        bestSignalLocation: Coordinate
    for x, row in m.pairs:
        for y, val in row.pairs:
            case val:
            of CURENT_POSITION: currentPosition = (x, y)
            of BEST_SIGNAL_LOCATION: bestSignalLocation = (x, y)
            else: discard

    return (currentPosition, bestSignalLocation)

let (currentPosition, bestSignalLocation) = heightmap.currentPositionAndBestSignalLocation()

func rows(m: HeightMap): int {.inline.} =
    return m.len

func cols(m: HeightMap): int {.inline.} =
    return m[0].len

func elevation(val: char): char =
    case val:
    of CURENT_POSITION: result = LOWEST_ELEVATION
    of BEST_SIGNAL_LOCATION: result = HIGHEST_ELEVATION
    else: result = val

iterator neighbors(m: HeightMap, loc: Coordinate): Coordinate =
    var potentialLocs: seq[Coordinate]
    if loc.x - 1 >= 0:
        potentialLocs.add((loc.x - 1, loc.y))
    if loc.x + 1 < m.rows:
        potentialLocs.add((loc.x + 1, loc.y))
    if loc.y - 1 >= 0:
        potentialLocs.add((loc.x, loc.y - 1))
    if loc.y + 1 < m.cols:
        potentialLocs.add((loc.x, loc.y + 1))

    let elevation = m[loc.x][loc.y].elevation
    for l in potentialLocs:
        if m[l.x][l.y].elevation <= char(elevation.ord + 1):
            yield l

func minStepsRequired(
    m: HeightMap,
    starts: seq[Coordinate],
    finish: Coordinate
): int =
    var hq = starts.mapIt((0, it)).toHeapQueue
    var visited: Table[Coordinate, int]

    while hq.len != 0:
        let (steps, loc) = hq.pop()

        if loc == finish:
            result = steps
            break

        for neighbor in m.neighbors(loc):
            let nextSteps = steps + 1
            if nextSteps < visited.getOrDefault(neighbor, int.high):
                visited[neighbor] = nextSteps
                hq.push((nextSteps, neighbor))

echo "Part 1: ", heightmap.minStepsRequired(@[currentPosition], bestSignalLocation)

iterator aElevationSquares(m: HeightMap): Coordinate =
    for x, row in m.pairs:
        for y, val in row.pairs:
            if val == LOWEST_ELEVATION:
                yield (x, y)

echo "Part 2: ", heightmap.minStepsRequired(heightmap.aElevationSquares.toSeq, bestSignalLocation)
