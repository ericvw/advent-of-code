import std/algorithm
import std/sequtils
import std/sets
import std/sugar
import std/tables

let scan = collect:
    for line in stdin.lines:
        line

type
    Coordinate = object
        x, y: int

func `+`(a, b: Coordinate): Coordinate =
    result.x = a.x + b.x
    result.y = a.y + b.y

const ELF = '#'

let elves = collect:
    for x, row in scan:
        for y, c in row:
            if c == ELF:
                {Coordinate(x: x, y: y)}

type
    Direction = enum
        North
        East
        South
        West

const NEIGHBOR_STEP = [
    Coordinate(x: -1, y: -1), # NW
    Coordinate(x: -1, y: 0),  # N
    Coordinate(x: -1, y: 1),  # NE
    Coordinate(x: 0, y: -1),  # W
    Coordinate(x: 0, y: 1),   # E
    Coordinate(x: 1, y: -1),  # SW
    Coordinate(x: 1, y: 0),   # S
    Coordinate(x: 1, y: 1),   # SE
]

func nearbyElves(elf: Coordinate, elves: HashSet[Coordinate]): seq[Coordinate] =
    for step in NEIGHBOR_STEP:
        let neighborLoc = elf + step
        if neighborLoc in elves:
            result.add(step)

const DIRECTIONS: array[Direction, array[3, Coordinate]] = [
    [
        Coordinate(x: -1, y: 0),  # N
        Coordinate(x: -1, y: 1),  # NE
        Coordinate(x: -1, y: -1), # NW
    ],
    [
        Coordinate(x: 0, y: 1),   # E
        Coordinate(x: -1, y: 1),  # NE
        Coordinate(x: 1, y: 1),   # SE
    ],
    [
        Coordinate(x: 1, y: 0),   # S
        Coordinate(x: 1, y: 1),   # SE
        Coordinate(x: 1, y: -1),  # SW
    ],
    [
        Coordinate(x: 0, y: -1),  # W
        Coordinate(x: -1, y: -1), # NW
        Coordinate(x: 1, y: -1),  # SW
    ],
]

func moveProposals(
    elves: HashSet[Coordinate],
    directions: seq[Direction],
): seq[(Coordinate, Direction)] =

    for elf in elves:
        let neighbors = nearbyElves(elf, elves)
        if neighbors.len == 0:
            continue

        block directionLoop:
            for d in directions:
                let adjacentLocs = DIRECTIONS[d]
                block adjacentLoop:
                    for loc in adjacentLocs:
                        if loc in neighbors:
                            break adjacentLoop

                    result.add((elf, d))
                    break directionLoop

const INIT_DIRECTIONS = [
    North,
    South,
    West,
    East,
]

type
    Move = tuple
        src, dst: Coordinate

func uniqueMoves(proposedMoves: seq[(Coordinate, Direction)]): seq[Move] =
    let moves: seq[Move] = collect:
        for (elf, dir) in proposedMoves:
            (elf, elf + DIRECTIONS[dir][0])

    var dstCounts = moves.map((m) => m.dst).toCountTable
    for m in moves:
        if dstCounts[m.dst] == 1:
            result.add(m)

func rectangleBounds(elves: HashSet[Coordinate]): (int, int, int, int) =
    var minX = int.high
    var minY = int.high
    var maxX = int.low
    var maxY = int.low

    for elf in elves:
        minX = min(elf.x, minX)
        minY = min(elf.y, minY)
        maxX = max(elf.x, maxX)
        maxY = max(elf.y, maxY)

    (minX, minY, maxX, maxY)

type
    SimulationResult = object
        elves: HashSet[Coordinate]
        rounds: int

func simulateProcess(
    elves: HashSet[Coordinate],
    limit: int = 0,
): SimulationResult =

    result.elves = elves
    result.rounds = 0

    let limitRounds = (limit != 0)

    var rules = @INIT_DIRECTIONS
    while true:
        inc(result.rounds)

        let proposedDirs = moveProposals(result.elves, rules)
        let uniqueMoves = uniqueMoves(proposedDirs)
        if uniqueMoves.len == 0:
            break

        for m in uniqueMoves:
            result.elves.excl(m.src)
            result.elves.incl(m.dst)

        rules.rotateLeft(1)

        if limitRounds and result.rounds == limit:
            break

func emptyGroundTiles(elves: HashSet[Coordinate]): int =
    let (minX, minY, maxX, maxY) = rectangleBounds(elves)
    ((maxX - minX + 1) * (maxY - minY + 1)) - elves.len

echo "Part 1: ", emptyGroundTiles(simulateProcess(elves, 10).elves)
echo "Part 2: ", simulateProcess(elves).rounds
