import std/deques
import std/sequtils
import std/strscans
import std/strutils

type
    Supplies = seq[Deque[char]]
    RearrangementProcedure = tuple[quantity, src, dst: int]
    RearrangementProcedures = seq[RearrangementProcedure]

var startingStacks: seq[string]
for line in stdin.lines:
    if line.len == 0:
        break
    startingStacks.add(line)

let suppliesLen = ord(startingStacks.pop().strip()[^1]) - ord('0')
# XXX: Can't do the following as an argument due to https://github.com/nim-lang/Nim/issues/21538.
#ord(startingStacks.pop().strip()[^1]) - ord('0'),
var initSupplies: Supplies = newSeqWith(
    suppliesLen,
    initDeque[char](startingStacks.len)
)

const
    CRATE_START = 1
    CRATE_DELTA = 4

iterator reverse[T](a: seq[T]): T {.inline.} =
    var i = len(a) - 1
    while i >= 0:
        yield a[i]
        dec(i)

for line in startingStacks.reverse:
    var i = CRATE_START
    while i < line.len:
        let crate = line[i]
        if not crate.isSpaceAscii:
            initSupplies[(i - CRATE_START) div CRATE_DELTA].addLast(crate)
        inc(i, CRATE_DELTA)

var procedures: RearrangementProcedures
for line in stdin.lines:
    let (success, num, src, dst) = line.scanTuple("move $i from $i to $i")
    assert success
    procedures.add((num, src - 1, dst - 1))

var supplies = initSupplies
for (quantity, src, dst) in procedures:
    for i in 1..quantity:
        supplies[dst].addLast(supplies[src].popLast)

echo "Part 1: ", supplies.mapIt(it[^1]).join

supplies = initSupplies
for (quantity, src, dst) in procedures:
    var tmp: Deque[char]
    for i in 1..quantity:
        tmp.addLast(supplies[src].popLast)
    while tmp.len > 0:
        supplies[dst].addLast(tmp.popLast)

echo "Part 2: ", supplies.mapIt(it[^1]).join
