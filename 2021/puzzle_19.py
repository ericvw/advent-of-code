from collections import Counter
from collections import deque
from dataclasses import dataclass
import fileinput
from itertools import combinations
import math
from operator import add
from typing import Generator
from typing import cast

# Constants
COMMON_BEACON_THRESHOLD = 12

# Types
Coordinate = tuple[int, int, int]


@dataclass
class Scanner:
    id: int
    beacons: set[Coordinate]
    position: Coordinate

    def __init__(self, id: int, beacons: set[Coordinate]):
        self.id = id
        self.beacons = beacons


def turn(c: Coordinate) -> Coordinate:
    return (-c[1], c[0], c[2])


def roll(c: Coordinate) -> Coordinate:
    return (c[0], c[2], -c[1])


def orientations(c: Coordinate) -> Generator[Coordinate, None, None]:
    for _ in range(2):
        for _ in range(3):
            c = roll(c)
            yield c
            for _ in range(3):
                c = turn(c)
                yield c
        c = roll(turn(roll(c)))


UNIQUE_ORIENTATIONS = 24
ORIENTATIONS = list(orientations((1, 2, 3)))
assert len(ORIENTATIONS) == UNIQUE_ORIENTATIONS


# Functions
def manhattan_distance(p1: Coordinate, p2: Coordinate) -> int:
    return sum(map(lambda a, b: abs(a - b), p1, p2))


def apply_orientation(c: Coordinate, orientation: tuple[int, int, int]) -> Coordinate:
    return cast(
        Coordinate,
        tuple(map(lambda o: int(math.copysign(1, o)) * c[abs(o) - 1], orientation)),
    )


def align_scanner(scanner: Scanner, beacons: set[Coordinate]) -> bool:
    for o in ORIENTATIONS:
        reoriented_beacons = [apply_orientation(b, o) for b in scanner.beacons]
        deltas = Counter(
            (x2 - x1, y2 - y1, z2 - z1)
            for x1, y1, z1 in reoriented_beacons
            for x2, y2, z2 in beacons
        )
        translation, count = deltas.most_common(1)[0]
        if count >= COMMON_BEACON_THRESHOLD:
            scanner.position = translation
            scanner.beacons = set(
                cast(Coordinate, tuple(map(add, b, translation)))
                for b in reoriented_beacons
            )
            return True

    return False


# Parse
report: list[set[Coordinate]] = []
for line in filter(lambda x: x, (line.rstrip() for line in fileinput.input())):
    if "scanner" in line:
        report.append(set())
    else:
        report[-1].add(cast(Coordinate, tuple(map(int, line.split(",")))))


# Init
scanners = [Scanner(i, beacons) for i, beacons in enumerate(report)]
unidentified_scanners = deque(scanners)

scanner = unidentified_scanners.popleft()
assert scanner.id == 0
scanner.position = (0, 0, 0)

beacons = set(scanner.beacons)

# Main
while unidentified_scanners:
    scanner = unidentified_scanners.popleft()
    if align_scanner(scanner, beacons):
        beacons |= scanner.beacons
    else:
        unidentified_scanners.append(scanner)

print("Part 1:", len(beacons))

print(
    "Part 2:",
    max(
        manhattan_distance(a, b)
        for a, b in combinations((s.position for s in scanners), 2)
    ),
)
