"""
To understand the solution below, an analysis and understanding of the input
is required.

Notable observations:

* The program is 14 sets of 18 instructions.
* Each set has the exact same instructions with the last operand being different.

The general form of each set is as follows:

     1. inp w

     2. mul x 0
     3. add x z
     4. mod x 26
     5. div z {DIVISOR}
     6. add x {DISCRIMINATOR}
     7. eql x w
     8. eql x 0  # x = 1 if {DISCRIMINATOR} > 0

     9. mul y 0
    10. add y 25
    11. mul y x
    12. add y 1
    13. mul z y

    14. mul y 0
    15. add y w
    16. add y {OFFSET}
    17. mul y x
    18. add z y

Looking at the input we observe the following:

* The input digit is always stored in w.
* The values in w, x, and y is reset and z is the only values that persists.
* {DIVISOR} is always either 1 or 26 depending on whether {DISCRIMINATOR} is
  positive or negative, respectively.
* If {DISCRIMINATOR} is positive, it's always > 9
* There are equal number of sets (7) where {DISCRIMINATOR} is positive and negative.
* When {DISCRIMINATOR}

Simplifying the program noticing that z is treated like a base-26 number:

Read input digit.
if {DISCRIMINATOR} > 0:
    z = input + {OFFSET}
else:
    z = z // 26
    if z + {DISCRIMINATOR} + {OFFSET} != input:
        z = input + {OFFSET}

Essentially we can treat the z register as a stack because when {DISCRIMINATOR}
is negative, it is exacting the last value pushed (i.e., w + {OFFSET}).
Ideally, we want the stack to be empty which signals that z is 0, otherwise it
has some other value; thus we need equal pushes and pops.

For that to happens, we need to maintain the following constraint:

    w_prev + {OFFSET}_prev + {OFFSET} == w_cur

Simplifying DELTA = {OFFSET}_prev + {OFFSET}:

    w_prev + {DELTA} == w_cur

For the largest model number, we know one digit must be 9, and the other will
be 9 - {DELTA} if DELTA > 0 else 9 + {DELTA}.
"""

from collections import deque
from dataclasses import dataclass
from enum import IntEnum
from enum import StrEnum
import fileinput
from typing import cast
from typing import Iterable
from typing import Sequence
from typing import TypeVar


class InstructionType(StrEnum):
    INPUT = "inp"
    ADD = "add"
    MULTIPLY = "mul"
    DIVIDE = "div"
    MODULO = "mod"
    EQUAL = "eql"


class ALURegister(StrEnum):
    w = "w"
    x = "x"
    y = "y"
    z = "z"


@dataclass
class Instruction:
    type: InstructionType
    a: ALURegister
    b: ALURegister | int | None = None

    def __str__(self) -> str:
        result = f"{self.type.value} {self.a.value}"
        if self.b:
            result += f" {str(self.b)}"
        return result

    def __repr__(self) -> str:
        result = f"Instruction({self.type.value}, {self.a.value}"
        if self.b:
            result += f", {str(self.b)}"
        result += ")"
        return result


def int_or_var(x: str) -> ALURegister | int:
    try:
        return int(x)
    except ValueError:
        return ALURegister(x)


def input2instruction(x: str) -> Instruction:
    tokens = x.split()
    return Instruction(
        InstructionType(tokens[0]),
        ALURegister(tokens[1]),
        None if len(tokens) == 2 else int_or_var(tokens[2]),
    )


monad_program_input = [input2instruction(line.rstrip()) for line in fileinput.input()]

NUM_DIGITS = 14
BASE = 26


class InstructionLine(IntEnum):
    DIVISOR = 4
    DISCRIMINATOR = 5
    OFFSET = 15


T = TypeVar("T")


def chunk(s: Sequence[T], size: int) -> Iterable[Sequence[T]]:
    for i in range(0, len(s), size):
        yield s[i : i + size]


@dataclass
class Constraint:
    digit_i: int
    digit_j: int
    delta: int


def extract_constraints(program: list[Instruction]) -> Sequence[Constraint]:
    constraints: list[Constraint] = []
    stack: deque[tuple[int, int]] = deque()

    for i, instruction_set in enumerate(chunk(program, len(program) // NUM_DIGITS)):
        if instruction_set[InstructionLine.DIVISOR].b == BASE:
            digit_i, offset_prev = stack.pop()
            offset_cur = cast(int, instruction_set[InstructionLine.DISCRIMINATOR].b)
            constraints.append(Constraint(i, digit_i, offset_prev + offset_cur))

        else:
            stack.append((i, cast(int, instruction_set[InstructionLine.OFFSET].b)))

    return constraints


constraints = extract_constraints(monad_program_input)
assert len(constraints) == NUM_DIGITS // 2


def largest_model_number(constraints: Iterable[Constraint]) -> int:
    digits = [0] * NUM_DIGITS

    for c in constraints:
        i = c.digit_i
        j = c.digit_j
        delta = c.delta

        if delta > 0:
            digits[i], digits[j] = 9, 9 - delta
        else:
            digits[i], digits[j] = 9 + delta, 9

    return int("".join(map(str, digits)))


print("Part 1:", largest_model_number(constraints))


def smallest_model_number(constraints: Iterable[Constraint]) -> int:
    digits = [0] * NUM_DIGITS

    for c in constraints:
        i = c.digit_i
        j = c.digit_j
        delta = c.delta

        if delta > 0:
            digits[i], digits[j] = 1 + delta, 1
        else:
            digits[i], digits[j] = 1, 1 - delta

    return int("".join(map(str, digits)))


print("Part 2:", smallest_model_number(constraints))
