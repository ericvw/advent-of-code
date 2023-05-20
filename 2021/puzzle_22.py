from dataclasses import dataclass
from enum import IntEnum
import fileinput
from typing import Sequence


# Types
class CubeState(IntEnum):
    OFF = -1
    ON = 1


@dataclass
class Cuboid:
    # XXX: Ranges are inclusive (i.e., stop + 1).
    x: range
    y: range
    z: range

    @property
    def cubes(self) -> int:
        return len(self.x) * len(self.y) * len(self.z)

    def __and__(self, other: "Cuboid") -> "Cuboid":
        return Cuboid(
            range(max(self.x.start, other.x.start), min(self.x.stop, other.x.stop)),
            range(max(self.y.start, other.y.start), min(self.y.stop, other.y.stop)),
            range(max(self.z.start, other.z.start), min(self.z.stop, other.z.stop)),
        )


@dataclass
class StatefulCuboid:
    cuboid: Cuboid
    sign: int

    @property
    def volume(self) -> int:
        return self.sign * self.cuboid.cubes

    def __and__(self, other: "StatefulCuboid") -> "StatefulCuboid":
        return StatefulCuboid(self.cuboid & other.cuboid, -other.sign)


@dataclass
class RebootStep:
    state: CubeState
    cuboid: Cuboid


# Functions
def create_inclusive_range(start: int, end: int) -> range:
    return range(start, end + 1)


# Parse
reboot_steps: list[RebootStep] = []
for line in fileinput.input():
    input_state, input_coordinates = line.rstrip().split()
    state = CubeState[input_state.upper()]
    cuboid = Cuboid(
        **dict(
            map(
                lambda c: (
                    c[0],
                    create_inclusive_range(*map(int, c[1].split(".."))),
                ),
                (x.split("=") for x in input_coordinates.split(",")),
            )
        )
    )
    reboot_steps.append(RebootStep(state, cuboid))

reboot_steps_within_50 = [
    s
    for s in reboot_steps
    if (
        s.cuboid
        & Cuboid(
            create_inclusive_range(-50, 50),
            create_inclusive_range(-50, 50),
            create_inclusive_range(-50, 50),
        )
    )
    == s.cuboid
]


# Main
def reboot_reactor(reboot_sequence: Sequence[RebootStep]) -> int:
    cubes: list[StatefulCuboid] = []

    for step in reboot_sequence:
        cube = StatefulCuboid(step.cuboid, step.state)
        cubes.extend(
            [intersection for c in cubes if (intersection := cube & c).volume != 0]
        )

        if step.state == CubeState.ON:
            cubes.append(cube)

    return sum(c.volume for c in cubes)


lit_count = reboot_reactor(reboot_steps_within_50)
print("Part 1:", lit_count)

lit_count = reboot_reactor(reboot_steps)
print("Part 2:", lit_count)
