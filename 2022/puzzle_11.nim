import std/algorithm
import std/deques
import std/sequtils
import std/strscans
import std/strutils
import std/sugar

type
    Operator = enum
        MULTIPLY = "*"
        ADD = "+"

    OperationState = object
        operator: Operator
        operand: string

    TestState = object
        divisor: int
        trueMonkey: int
        falseMonkey: int

    Monkey = object
        id: int
        items: Deque[int]
        operation: OperationState
        test: TestState

func matchItems(input: string, items: var seq[int], start: int): int =
    for inItem in input[start .. ^1].split(", "):
        items.add(inItem.parseInt)
    result = input.len - start

iterator parseMonkeys(input: File): Monkey =
    var line: string
    while input.readLine(line):
        var id: int
        if not scanf(line, "Monkey $i:$.", id):
            break

        var items: seq[int]
        if not scanf(input.readLine, "$sStarting items: ${matchItems}$.", items):
            break

        var operator: char
        var operand: string
        if not scanf(input.readLine, "$sOperation: new = old $c $+$.", operator, operand):
            break

        var divisor: int
        if not scanf(input.readLine, "$sTest: divisible by $i$.", divisor):
            break

        var trueMonkey: int
        if not scanf(input.readLine, "$sIf true: throw to monkey $i$.", trueMonkey):
            break

        var falseMonkey: int
        if not scanf(input.readLine, "$sIf false: throw to monkey $i$.", falseMonkey):
            break

        yield Monkey(
            id: id,
            items: items.toDeque,
            operation: OperationState(
                operator: parseEnum[Operator]($operator),
                operand: operand,
            ),
            test: TestState(
                divisor: int(divisor),
                trueMonkey: trueMonkey,
                falseMonkey: falseMonkey,
            ),
        )

        try:
            # XXX: Consume blank line between input.
            discard input.readLine
        except IOError:
            break

func execOperation(m: Monkey, old: int): int =
    var rhs: int
    if m.operation.operand == "old":
        rhs = old
    else:
        rhs = m.operation.operand.parseInt

    case m.operation.operator:
    of MULTIPLY: old * rhs
    of ADD: old + rhs

func execTest(m: Monkey, x: int): int =
    if x mod m.test.divisor == 0: m.test.trueMonkey
    else: m.test.falseMonkey

var monkeys: seq[Monkey]
for monkey in parseMonkeys(stdin):
    assert monkey.id == monkeys.len
    monkeys.add(monkey)

# XXX: For Part 2, without division by the relief factor, the numbers become
#      too large to work with, even for unsigned integers. However, the
#      divisors are all prime; thus, we can take their product to modulo the
#      operation value to still yield the correct result.
#      i.e., (n % (p * q)) % q == n % q
let divisorProduct = foldl(monkeys.map((m) => m.test.divisor), a * b)

proc monkeyBusiness(
    monkeysInit: seq[Monkey],
    rounds: int,
    reliefFactor: int = 1
): int =
    var monkeys = monkeysInit

    var inspectedItems = newSeqWith(monkeys.len, 0)
    for round in 1 .. rounds:
        for monkey in monkeys.mitems:
            while monkey.items.len > 0:
                inspectedItems[monkey.id].inc
                var worryLevel = monkey.items.popFirst
                worryLevel = monkey.execOperation(worryLevel) mod divisorProduct
                worryLevel = worryLevel div reliefFactor
                monkeys[monkey.execTest(worryLevel)].items.addLast(worryLevel)

    foldl(inspectedItems.sorted()[^2..^1], a * b)

echo "Part 1: ", monkeyBusiness(monkeys, 20, 3)

echo "Part 2: ", monkeyBusiness(monkeys, 10_000)
