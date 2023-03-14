import std/sequtils
import std/strutils

type
    Assignment = set[int8]
    AssignmentPair = (Assignment, Assignment)

var
    assignmentPairs: seq[AssignmentPair]
    line: string

proc toAssignment(input: string): Assignment =
    let range = input.split('-')
    {cast[int8](range[0].parseInt) .. cast[int8](range[1].parseInt)}

while stdin.readLine(line):
    let pair = line.split(',')
    assignmentPairs.add((pair[0].toAssignment, pair[1].toAssignment))

let numContains = assignmentPairs.countIt(it[0] <= it[1] or it[1] <= it[0])
echo "Part 1: ", numContains

let numOveralp = assignmentPairs.countIt((it[0] * it[1]).card != 0)
echo "Part 2: ", numOveralp
