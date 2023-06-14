from enum import StrEnum
import fileinput
from typing import Iterable


class SeaCucumberHerdType(StrEnum):
    EAST = ">"
    SOUTH = "v"


Location = SeaCucumberHerdType | None
SeaMap = list[list[Location]]


sea_map: SeaMap = [
    [None if x == "." else SeaCucumberHerdType(x) for x in line.rstrip()]
    for line in fileinput.input()
]

Coordinate = tuple[int, int]
Change = tuple[Coordinate, Location]


def coordinates(m: SeaMap, t: SeaCucumberHerdType) -> Iterable[tuple[int, int]]:
    return ((r, c) for r, row in enumerate(m) for c, x in enumerate(row) if x == t)


def steps_until_no_movement(m: SeaMap) -> int:
    rows = len(m)
    cols = len(m[0])

    steps = 0
    while True:
        steps += 1
        east_changes: list[Change] = []
        south_changes: list[Change] = []

        for i, j in coordinates(m, SeaCucumberHerdType.EAST):
            next_j = (j + 1) % cols
            if m[i][next_j]:
                continue
            east_changes.append(((i, next_j), SeaCucumberHerdType.EAST))
            east_changes.append(((i, j), None))

        for c in east_changes:
            (i, j), loc = c
            m[i][j] = loc

        for i, j in coordinates(m, SeaCucumberHerdType.SOUTH):
            next_i = (i + 1) % rows
            if m[next_i][j]:
                continue
            south_changes.append(((next_i, j), SeaCucumberHerdType.SOUTH))
            south_changes.append(((i, j), None))

        for c in south_changes:
            (i, j), loc = c
            m[i][j] = loc

        if not east_changes and not south_changes:
            break

    return steps


print("Part 1:", steps_until_no_movement(sea_map))
