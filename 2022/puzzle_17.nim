import std/algorithm
import std/endians
import std/sequtils
import std/strutils
import std/sugar
import std/tables

func cycle[T](s: openArray[T]): iterator(): T =
    # XXX: Capture a local copy because openArray is a pointer and length.
    let s = @s
    iterator(): T =
        var i = 0
        while true:
            yield s[i]
            i = (i + 1) mod s.len
const
    PUSH_LEFT = '<'
    PUSH_RIGHT = '>'

type
    JetDirection = enum
        LEFT
        RIGHT

var jetPattern = collect:
    for direction in stdin.readAll().strip():
        if direction == PUSH_LEFT:
            LEFT
        else:
            assert direction == PUSH_RIGHT
            RIGHT

type
    JetPatternIter = object
        pattern: seq[JetDirection]
        idx: int = 0

proc next(self: var JetPatternIter): JetDirection =
    result = self.pattern[self.idx]
    self.idx = (self.idx + 1) mod self.pattern.len

# Rocks are represented as unsigned 32 bit integers. This makes collision
# detection easier by using bit manipulations while keeping the representation
# compact. However, it makes the code a bit more complicated to read.
type
    Rock = uint32

# The binary representation of each rock that fits within an unsigned 32 bit
# integer:
#
# ...1111.  ....1...  .....1..  ...1....  ...11...
# ........  ...111..  .....1..  ...1....  ...11...
# ........  ....1...  ...111..  ...1....  ........
# ........  ........  ........  ...1....  ........
#
# Note that the rocks are two units away from the left edge (see below).
const ROCKS: array[5, Rock] = [
    0x0000001E,
    0x00081C08,
    0x0004041C,
    0x10101010,
    0x00001818,
]

# The binary representation of the walls are visualized as follows:
#
# 1.......  .......1
# 1.......  .......1
# 1.......  .......1
# 1.......  .......1
const
    LEFT_WALL = 0x40404040'u32
    RIGHT_WALL = 0x01010101'u32
    START_HEIGHT_DELTA = 3

func collides(rock: Rock, obj: uint32): bool {.inline.} =
    (rock and obj) > 0

func push(rock: Rock, direction: JetDirection, chunk: uint32): Rock =
    result = rock

    case direction
    of LEFT:
        if not collides(rock, LEFT_WALL):
            result = rock shl 1
    of RIGHT:
        if not collides(rock, RIGHT_WALL):
            result = rock shr 1

    if result.collides(chunk):
        # The rock can't be pushed if it collides with another rock in the
        # chamber.
        result = rock

iterator bytes(rock: Rock): uint8 =
    var leBytes: array[4, uint8]
    # XXX: Ensure bytes are in a predictable order regardless of architecture.
    littleEndian32(addr leBytes, addr rock)
    for bytes in leBytes:
        if bytes > 0:
            yield bytes

type
    Chamber = object
        patternIter: JetPatternIter
        chamber: seq[uint8]

    Chunk = uint32
    DoubleChunk = uint64

func getChunk(self: Chamber, height: int): Chunk =
    ## Obtain a 4 height chunk of bytes from the chamber.
    if height >= self.chamber.len:
        return 0
    # XXX: Clamp second slice to stay within bounds.
    # XXX: Reverse the order to get the correct rock orientation!
    self.chamber[height .. ^1][0 ..< min(self.chamber.len - height, sizeof(Chunk))]
        .reversed
        .foldl((a shl 8) or b, 0'u32)

func getTopDoubleChunk(self: Chamber): DoubleChunk =
    ## Obtain a 8 height chunk of bytes from the chamber.
    if self.chamber.len < sizeof(DoubleChunk):
        return 0
    # XXX: Reverse the order to get the correct rock orientation!
    self.chamber[self.chamber.len - sizeof(uint64) .. ^1]
        .reversed
        .foldl((a shl 8) or b, 0'u64)

proc settle(self: var Chamber, rock: Rock, level: int) =
    var lvl = level
    for byte in rock.bytes:
        if lvl < self.chamber.len:
            self.chamber[lvl] = self.chamber[lvl] or byte
        else:
            self.chamber.add(byte)
        inc(lvl)

proc fallIntoPlace(self: var Chamber, rock: Rock) =
    var fallingRock = rock
    var height = self.chamber.len + START_HEIGHT_DELTA

    while true:
        # Push the rock around.
        fallingRock = fallingRock.push(
            self.patternIter.next(),
            self.getChunk(height)
        )

        if height > self.chamber.len:
            # Continue falling because the rock is still above where it could
            # collide with another rock that has settled in the chamber.
            dec(height)
            continue

        if height == 0 or fallingRock.collides(self.getChunk(height - 1)):
            # If the rock hits the floor or collides with another rock, add the
            # settled rock to the chamber.
            self.settle(fallingRock, height)
            break

        # Free falling…
        dec(height)

func height(self: Chamber): int {.inline.} =
    self.chamber.len

proc towerHeight(numRocks: int): int =
    var chamber = Chamber(patternIter: JetPatternIter(pattern: jetPattern))
    let rockIter = cycle(ROCKS)

    for _ in 0 ..< numRocks:
        chamber.fallIntoPlace(rockIter())

    chamber.height

echo "Part 1: ", towerHeight(2022)

proc towerHeightWithCycleDetection(numRocks: int): int =
    var chamber = Chamber(patternIter: JetPatternIter(pattern: jetPattern))
    let rockIter = cycle(ROCKS)
    var seen = initTable[(uint64, Rock, int), (int, int)]()

    var rocksFallen = 0
    var cycleHeight = 0
    while rocksFallen < numRocks:
        let rock = rockIter()
        chamber.fallIntoPlace(rock)
        inc(rocksFallen)

        # XXX: The rock configuration, the most recent rock, and the where we
        # are in the jet pattern triplet is the unique state we need to look
        # for in a cycle.
        let state = (
            chamber.getTopDoubleChunk(),
            rock,
            chamber.patternIter.idx,
        )
        if (let prevState = seen.getOrDefault(state); prevState) != (0, 0):
            let (prevRocksFallen, prevHeight) = prevState
            let rocksPerCycle = rocksFallen - prevRocksFallen
            let numCycles = (numRocks - rocksFallen) div rocksPerCycle

            # Add the number of rocks contributed from repeating cycles.
            rocksFallen += rocksPerCycle * numCycles

            # Add the height contributed to the repeating cycles.
            cycleHeight += (chamber.height - prevHeight) * numCycles

            # Clear previous observed states because we have already
            # factored-in the most recent repeating cycle.
            seen.clear()
            continue

        # Capture metadata for calculating total height for this particular
        # state.
        seen[state] = (rocksFallen, chamber.height)

    chamber.height + cycleHeight

echo "Part 2: ", towerHeightWithCycleDetection(1_000_000_000_000)
