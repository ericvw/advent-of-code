import std/math
import std/sequtils
import std/sets
import std/strutils

type
    Items = string
    Rucksack = seq[Items]

var
    rucksacks: Rucksack
    line: string

while stdin.readLine(line):
    rucksacks.add(line)

const
    LOWER_PRIORITY_BASE = 1
    UPPER_PRIORITY_BASE = 27

proc priority(item: char): int =
    if item.isLowerAscii:
        LOWER_PRIORITY_BASE + item.ord - 'a'.ord
    else:
        UPPER_PRIORITY_BASE + item.ord - 'A'.ord

echo "Part 1: ", rucksacks.map(proc(items: Items): char =
    var common = items[0 ..< items.len div 2].toHashSet *
                 items[items.len div 2 .. ^1].toHashSet
    assert common.len == 1
    common.pop
).map(priority).sum

const ELVES_PER_GROUP = 3

echo "Part 2: ", rucksacks.distribute(
    rucksacks.len div ELVES_PER_GROUP,
    spread = false
).map(proc(group: seq[Items]): char =
    var common = group[0].toHashSet * group[1].toHashSet * group[2].toHashSet
    assert common.len == 1
    common.pop
).map(priority).sum
