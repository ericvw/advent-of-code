import bisect
from collections import deque
from dataclasses import dataclass
from enum import StrEnum
import fileinput
import heapq
from itertools import chain
from itertools import takewhile
import sys
from typing import Iterable
from typing import Iterator
from typing import Sequence


class AmphipodType(StrEnum):
    AMBER = "A"
    BRONZE = "B"
    COPPER = "C"
    DESERT = "D"


MOVE_COST = {
    AmphipodType.AMBER: 1,
    AmphipodType.BRONZE: 10,
    AmphipodType.COPPER: 100,
    AmphipodType.DESERT: 1000,
}


class SpaceType(StrEnum):
    BLANK = " "
    OPEN = "."
    WALL = "#"


@dataclass
class Tile:
    passable: bool = False

    def __str__(self) -> str:
        if not self.passable:
            return SpaceType.WALL
        else:
            return SpaceType.OPEN


def space2tile(space: str) -> Tile:
    return Tile(passable=(space not in (SpaceType.BLANK, SpaceType.WALL)))


Coordinate = tuple[int, int]


@dataclass
class Diagram:
    # PUBLIC DATA
    tiles: list[list[Tile]]
    side_rooms: dict[AmphipodType, Sequence[Coordinate]]
    hallway_locations: list[Coordinate]
    valid_hallway_locations: Iterable[Coordinate]

    # DATA
    _loc_to_side_room_type: dict[Coordinate, AmphipodType]

    # PRIVATE ACCESSORS
    def __str__(self) -> str:
        return "\n".join("".join(str(tile) for tile in row) for row in self.tiles)

    # CREATORS
    def __init__(self, diagram: Sequence[str]):
        rows = len(diagram)
        cols = len(diagram[0])

        self.tiles = [[Tile()] * cols for _ in range(rows)]
        for x, icol in enumerate(diagram):
            for y, space in enumerate(icol):
                tile = space2tile(space)
                self.tiles[x][y] = tile

        side_room_order = deque(AmphipodType)
        self.side_rooms = {}
        for x, col in enumerate(self.tiles):
            if not side_room_order:
                break
            for y, _ in enumerate(col):
                if self.is_side_room((x, y)):
                    side_room = side_room_order.popleft()
                    self.side_rooms[AmphipodType(side_room)] = [
                        (x, y)
                        for x in range(x, len(self.tiles))
                        if self.tiles[x][y].passable
                    ]
        self._loc_to_side_room_type = {
            loc: atype for atype, locs in self.side_rooms.items() for loc in locs
        }

        self.hallway_locations = []
        self.valid_hallway_locations = set()
        for x, col in enumerate(self.tiles):
            for y, _ in enumerate(col):
                if self.is_hallway((x, y)):
                    self.hallway_locations.append((x, y))
                    if not self.is_side_room((x + 1, y)):
                        # Add location if not above a side room.
                        self.valid_hallway_locations.add((x, y))

    # ACCESSORS
    def tile(self, location: Coordinate) -> Tile:
        x, y = location
        return self.tiles[x][y]

    def hallway_type(self, location: Coordinate) -> AmphipodType:
        return self._loc_to_side_room_type[location]

    def is_side_room(self, location: Coordinate) -> bool:
        x, y = location
        return self.tile(location).passable and (
            self.tiles[x][y - 1].passable is False
            and self.tiles[x][y + 1].passable is False
        )

    def is_hallway(self, location: Coordinate) -> bool:
        x, y = location
        return self.tile(location).passable and (
            self.tiles[x][y - 1].passable or self.tiles[x][y + 1].passable
        )


@dataclass(frozen=True)
class Amphipod:
    type: AmphipodType
    location: Coordinate


Amphipods = frozenset[Amphipod]


class Board:
    # PUBLIC DATA
    diagram: Diagram
    amphipods: Amphipods

    # DATA
    _loc_lookup: dict[Coordinate, Amphipod]

    # PRIVATE ACCESSORS
    def __str__(self) -> str:
        output = [list(map(str, row)) for row in self.diagram.tiles]

        for a in self.amphipods:
            x, y = a.location
            output[x][y] = a.type

        return "\n".join("".join(char for char in row) for row in output)

    # CREATORS
    def __init__(self, diagram: Diagram, amphipods: Amphipods):
        self.diagram = diagram
        self.amphipods = amphipods
        self._loc_lookup = {a.location: a for a in amphipods}

    # ACCESSORS
    def moves(self, a: Amphipod) -> Iterator[Coordinate]:
        assert a in self.amphipods
        if self.diagram.is_hallway(a.location):
            if not self.side_room_ready(a):
                return
            elif self.hallway_path_to_side_room_blocked(a):
                return

            yield self.side_room_available_location(a)
        else:
            # Otherwise, the amphipod is in the side room.
            assert self.diagram.is_side_room(a.location)
            if self.at_destination(a):
                return
            if self.side_room_to_hallway_blocked(a):
                return

            for loc in self.side_room_to_hallway_locations(a):
                yield loc

    def side_room_ready(self, a: Amphipod) -> bool:
        assert a.location in self.diagram.valid_hallway_locations
        side_room_locs = self.diagram.side_rooms[a.type]
        return all(
            self._loc_lookup.get(loc, a).type == a.type for loc in side_room_locs
        )

    def hallway_path_to_side_room_blocked(self, a: Amphipod) -> bool:
        assert a.location in self.diagram.valid_hallway_locations
        side_room_locs = self.diagram.side_rooms[a.type]

        y_amphipod = a.location[1]

        # Extract y coordiante for the hallway above the side room.
        y_side_room = next(iter(side_room_locs))[1]

        # Find hallway space above side room for amphipod type.
        idx = bisect.bisect_left(
            self.diagram.hallway_locations, y_side_room, key=lambda loc: loc[1]
        )

        delta = abs(y_amphipod - y_side_room)
        if y_side_room < a.location[1]:
            # Amphipod is right of the side room.
            start = idx + 1
            end = idx + delta
        else:
            # Otherwise, left of the side room.
            start = idx - delta + 1
            end = idx

        return any(
            loc in self._loc_lookup for loc in self.diagram.hallway_locations[start:end]
        )

    def side_room_available_location(self, a: Amphipod) -> Coordinate:
        side_room_locs = self.diagram.side_rooms[a.type]
        return next(
            filter(lambda x: x not in self._loc_lookup, reversed(side_room_locs))
        )

    def side_room_to_hallway_blocked(self, a: Amphipod) -> bool:
        side_room_locs = self.diagram.side_rooms[self.diagram.hallway_type(a.location)]
        locs_above = list(takewhile(lambda x: x != a.location, side_room_locs))
        if not locs_above:
            return False
        return any(loc in self._loc_lookup for loc in locs_above)

    def side_room_to_hallway_locations(self, a: Amphipod) -> Iterable[Coordinate]:
        # Find hallway space above side room.
        idx = bisect.bisect_left(
            self.diagram.hallway_locations, a.location[1], key=lambda x: x[1]
        )

        left_locs = takewhile(
            lambda x: x not in self._loc_lookup,
            filter(
                lambda x: x in self.diagram.valid_hallway_locations,
                reversed(self.diagram.hallway_locations[:idx]),
            ),
        )
        right_locs = takewhile(
            lambda x: x not in self._loc_lookup,
            filter(
                lambda x: x in self.diagram.valid_hallway_locations,
                self.diagram.hallway_locations[idx + 1 :],
            ),
        )

        return chain(left_locs, right_locs)

    def at_destination(self, a: Amphipod) -> bool:
        dest_locs = self.diagram.side_rooms[a.type]
        return a.location in dest_locs and all(
            self._loc_lookup.get(loc, a).type == a.type for loc in dest_locs
        )

    def is_organized(self) -> bool:
        return all(
            a.location in self.diagram.side_rooms[a.type] for a in self.amphipods
        )


def parse_diagram(raw_diagram: list[str]) -> tuple[Diagram, Amphipods]:
    diagram = Diagram(raw_diagram)
    amphipods = []
    amphipod_types = frozenset(AmphipodType)
    for x, row in enumerate(raw_diagram):
        for y, space in enumerate(row):
            if space in amphipod_types:
                amphipods.append(Amphipod(AmphipodType(space), (x, y)))
    return diagram, Amphipods(amphipods)


def states(board: Board) -> Iterator[tuple[Amphipods, int]]:
    for a in board.amphipods:
        for dest in board.moves(a):
            ax, ay = a.location
            dx, dy = dest
            energy = MOVE_COST[a.type] * (abs(ax - dx) + abs(ay - dy))
            yield frozenset(filter(lambda x: x != a, board.amphipods)) | {
                Amphipod(a.type, dest)
            }, energy


def lowest_energy(init: Board) -> int:
    # Return the lowest energy to organize the amphipods in sorted order from
    # left-to-right.
    hq = [(0, init.amphipods)]
    seen_states: dict[Amphipods, int] = {}
    while hq:
        energy, amphipods = heapq.heappop(hq)
        board = Board(init.diagram, amphipods)

        if board.is_organized():
            return energy

        for amphipods, move_energy in states(board):
            new_energy = energy + move_energy
            if new_energy < seen_states.get(amphipods, sys.maxsize):
                seen_states[amphipods] = new_energy
                heapq.heappush(hq, (new_energy, amphipods))

    raise AssertionError("Amphipods should have been organized!")


diagram_input = [line.rstrip("\n") for line in fileinput.input()]
print("Part 1:", lowest_energy(Board(*parse_diagram(diagram_input))))

FOLD_INDEX = 3
diagram_input[FOLD_INDEX:FOLD_INDEX] = [
    "  #D#C#B#A#  ",
    "  #D#B#A#C#  ",
]

print("Part 2:", lowest_energy(Board(*parse_diagram(diagram_input))))
