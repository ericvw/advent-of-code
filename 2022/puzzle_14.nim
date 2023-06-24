import std/deques
import std/sequtils
import std/strutils
import std/sugar
import std/tables

type
    Coordinate = tuple[x, y: int]
    Path = seq[Coordinate]

func parsePath(s: string): Path =
    for rawCoordinate in s.split("->").mapIt(strip($it)):
        let numbers = rawCoordinate.split(',').map(parseInt)
        result.add((numbers[0], numbers[1]))

let rocks = collect:
    for line in stdin.lines:
        parsePath(line)

type
    Tile = enum
        Rock
        Sand

    Cave = Table[Coordinate, Tile]

func createCave(rocks: seq[Path]): Cave =
    iterator lineCoordinates(p1, p2: Coordinate): Coordinate =
        for x in min(p1.x, p2.x) .. max(p1.x, p2.x):
            for y in min(p1.y, p2.y) .. max(p1.y, p2.y):
                yield (x, y)

    for p in rocks:
        for (p1, p2) in zip(p[0 .. ^2], p[1 .. ^1]):
            for xy in lineCoordinates(p1, p2):
                result[xy] = Rock

let cave = createCave(rocks)

const SAND_SOURCE: Coordinate = (500, 0)

proc simulateFallingSand(
    cave: Cave,
    source: Coordinate,
    yMax: int,
    terminate: (Coordinate) -> bool,
): int =
    var c = cave

    var stack = [source].toDeque
    block simulation:
        while stack.len > 0:
            # We don't pop off the stack until we know the sand comes to rest.
            let xy = stack.peekLast()

            block comingToRest:
                for x in [0, -1, +1]:
                    let xyNext: Coordinate = (xy.x + x, xy.y + 1)
                    # XXX: We discover in Part 2 that there is a floor.
                    #      The floor is specified as 2 plus the maximium y scanned.
                    #      However, we use yMax + 1 because the sand can't rest at
                    #      the same y coordinate as the floor.
                    if not c.hasKey(xyNext) and xy.y < yMax + 1:
                        # Sand is is still in motion.
                        stack.addLast(xyNext)
                        break comingToRest

                # Sand can't go anywhere and is coming to rest.
                if terminate(xy):
                    break simulation

                # Sand at xy has come to rest.
                c[stack.popLast()] = Sand

    return c.len - cave.len

let yMax: int = cave.keys.toSeq.map(xy => xy[1]).max

echo "Part 1: ", simulateFallingSand(cave, SAND_SOURCE, yMax, (xy) => xy.y > yMax)

# XXX: Note the ' + 1' because the termination check occurs before the sand is
#      marked as coming to rest.
echo "Part 2: ",
      simulateFallingSand(cave, SAND_SOURCE, yMax, (xy) => xy == SAND_SOURCE) + 1
