import std/algorithm
import std/math
import std/sequtils
import std/sugar

let fuelRequirements = collect:
    for line in stdin.lines:
        line

const
    SNAFU_BASE = 5
    SNAFU_DIGITS = "=-012"
    ZERO_INDEX = 2

func snafuToDecimal(s: string): int =
    for i, c in s:
        result *= SNAFU_BASE
        result += SNAFU_DIGITS.find(c) - ZERO_INDEX

let decimalSum = sum(fuelRequirements.mapIt(snafuToDecimal(it)))

func decimalToSnafu(x: int): string =
    var n = x
    var r: int
    while n > 0:
        (n, r) = divmod(n + ZERO_INDEX, SNAFU_BASE)
        result &= SNAFU_DIGITS[r]
    result.reverse()

echo "Part 1: ", decimalToSnafu(decimalSum)
