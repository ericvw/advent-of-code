import fileinput
from itertools import starmap
import re
from typing import Generator

# Parse
xmin, xmax, ymin, ymax = map(int, re.findall(r"-?\d+", fileinput.input().readline()))


# Main
def generate_trajectory(
    x_v: int,
    y_v: int,
    x_bound: int,
    y_bound: int,
    *,
    x_start: int = 0,
    y_start: int = 0,
) -> Generator[tuple[int, int], None, None]:
    x_pos = x_start
    y_pos = y_start
    while x_pos <= x_bound and y_pos >= y_bound:
        yield (x_pos, y_pos)

        x_pos += x_v
        y_pos += y_v

        if x_v > 0:
            x_v -= 1
        elif x_v < 0:
            x_v += 1
        y_v -= 1


# For y velocities, we can aim directly at the lowest point in one step, and
# anything greater than -ymin overshoots when y_pos == 0 on the next step.
# Thus, ymin <= y_velocity <= -ymin.
valid_trajectories = [
    t
    for t in (
        list(generate_trajectory(x, y, xmax, ymin))
        for x in range(1, xmax + 1)
        for y in range(ymin, -ymin)
    )
    if any(starmap(lambda x, y: x >= xmin and y <= ymax, t))
]


# Result 1
highest_y = max(y for t in valid_trajectories for x, y in t)
print(f"Highest possible y position: {highest_y}")

# Result 2
print(f"Number of trajectories that land in target: {len(valid_trajectories)}")
