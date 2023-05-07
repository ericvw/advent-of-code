import std/deques
import std/math
import std/sequtils
import std/strutils
import std/sugar

type
    InstructionKind = enum
        NOOP = "noop"
        ADDX = "addx"

    Instruction = object
        case kind: InstructionKind:
        of NOOP:
            discard
        of ADDX:
            v: int

let instructions: seq[Instruction] = collect:
    for line in stdin.lines:
        let tokens = line.splitWhitespace()
        case parseEnum[InstructionKind](tokens[0]):
        of NOOP:
            Instruction(kind: NOOP)
        of ADDX:
            Instruction(kind: ADDX, v: parseInt(tokens[1]))

proc cyclesToComplete(instruction: Instruction): int =
    case instruction.kind:
    of NOOP: 1
    of ADDX: 2

const
    READING_CYCLES = @[
        20,
        60,
        100,
        140,
        180,
        220,
    ]

    SPRITE_WIDTH = 3
    CRT_WIDTH = 40
    CRT_HEIGHT = 6

type
    PixelState = enum
        ON = '#'
        OFF = '.'

    Pixel = char

    CRT = seq[Pixel]

proc pixelDrawnState(spritePos, cycle: int): PixelState =
    if abs(spritePos - cycle) <= SPRITE_WIDTH div 2: PixelState.ON
    else: PixelState.OFF

var signalStrengths = newSeqOfCap[int](READING_CYCLES.len)
var crt = newSeqWith(CRT_WIDTH * CRT_HEIGHT, PixelState.OFF.char)

var x = 1
var cycle = 0
var readingCycles = READING_CYCLES.toDeque
for instruction in instructions:
    for c in 0 ..< cyclesToComplete(instruction):
        crt[cycle] = char(pixelDrawnState(cycle div CRT_WIDTH * CRT_WIDTH + x, cycle))
        cycle += 1

    if readingCycles.len != 0 and cycle >= readingCycles.peekFirst:
        signalStrengths.add(readingCycles.popFirst * x)

    case instruction.kind:
    of ADDX:
        x += instruction.v
    else:
        discard

echo "Part 1: ", signalStrengths.sum

proc renderCrtString(crt: CRT): string =
    var screen = newSeqOfCap[string](CRT_HEIGHT)
    for row in 0 ..< CRT_HEIGHT:
        screen.add(crt[row * CRT_WIDTH ..< row * CRT_WIDTH + CRT_WIDTH].join)
    return screen.join("\n")

echo "Part 2:\n", renderCrtString(crt)
