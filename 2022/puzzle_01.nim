import std/algorithm
import std/math
import std/strutils

var
    elves: seq[seq[int]]
    calories: seq[int]
    line: string

while stdin.readLine(line):
    if len(line) == 0:
        elves.add(calories)
        calories.setLen(0)
    else:
        calories.add(parseInt(line))
elves.add(calories)

var maxCalories: int = 0
for calories in elves:
    maxCalories = max(sum(calories), maxCalories)

echo "Part 1: ", maxCalories

var summedCalories: seq[int]
for calories in elves:
    summedCalories.add(sum(calories))
sort(summedCalories)

let top3Sum = sum(summedCalories[^3..^1])

echo "Part 2: ", top3Sum
