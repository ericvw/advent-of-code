import std/sequtils
import std/strutils
import std/tables

var
    strategyGuide: seq[tuple[col1: char, col2: char]]
    line: string

while stdin.readLine(line):
    let round = line.splitWhitespace()
    assert round.len() == 2
    strategyGuide.add((round[0][0].char, round[1][0].char))

type
    Shape = enum
        Rock
        Paper
        Scissors

    RoundOutcome = enum
        Win
        Loss
        Draw

const
    ShapeScore = {
        Shape.Rock: 1,
        Shape.Paper: 2,
        Shape.Scissors: 3,
    }.toTable

    OutcomeScore = {
        RoundOutcome.Loss: 0,
        RoundOutcome.Draw: 3,
        RoundOutcome.Win: 6,
    }.toTable

    ShapeThem = {
        'A': Shape.Rock,
        'B': Shape.Paper,
        'C': Shape.Scissors,
    }.toTable

    ShapeUs = {
        'X': Shape.Rock,
        'Y': Shape.Paper,
        'Z': Shape.Scissors,
    }.toTable

proc playRound(us, them: Shape): RoundOutcome =
    result = RoundOutcome.Draw
    case us:
    of Shape.Rock:
        if them == Shape.Scissors:
            result = RoundOutcome.Win
        elif them == Shape.Paper:
            result = RoundOutcome.Loss
    of Shape.Paper:
        if them == Shape.Rock:
            result = RoundOutcome.Win
        elif them == Shape.Scissors:
            result = RoundOutcome.Loss
    of Shape.Scissors:
        if them == Shape.Paper:
            result = RoundOutcome.Win
        elif them == Shape.Rock:
            result = RoundOutcome.Loss

proc part1RoundScore(us, them: char): int =
    let
        usShape = ShapeUs[us]
        themShape = ShapeThem[them]

    ShapeScore[usShape] + OutcomeScore[playRound(usShape, themShape)]

var score = strategyGuide.foldl(a + part1RoundScore(b.col2, b.col1), 0)
echo "Part 1: ", score

const
    DecryptedOutcome = {
        'X': RoundOutcome.Loss,
        'Y': RoundOutcome.Draw,
        'Z': RoundOutcome.Win,
    }.toTable

proc shapeToAchieveOutcome(them: Shape, outcome: RoundOutcome): Shape =
    case outcome:
    of Draw:
        result = them
    of Win:
        case them:
            of Shape.Rock: result = Shape.Paper
            of Shape.Paper: result = Shape.Scissors
            of Shape.Scissors: result = Shape.Rock
    of Loss:
        case them:
            of Shape.Rock: result = Shape.Scissors
            of Shape.Paper: result = Shape.Rock
            of Shape.Scissors: result = Shape.Paper

proc part2RoundScore(outcome, them: char): int =
    let
        outcome = DecryptedOutcome[outcome]
        usShape = shapeToAchieveOutcome(ShapeThem[them], outcome)

    ShapeScore[usShape] + OutcomeScore[outcome]

score = strategyGuide.foldl(a + part2RoundScore(b.col2, b.col1), 0)
echo "Part 2: ", score
