from collections import deque
import fileinput
from itertools import islice
import math

# Parse
heightmap = [list(map(int, line.rstrip())) for line in fileinput.input()]

# Init
ROWS = len(heightmap)
COLS = len(heightmap[0])


# Main
def is_low_point(val: int, x: int, y: int) -> bool:
    return (
        (x - 1 < 0 or val < heightmap[x - 1][y])
        and (x + 1 >= ROWS or val < heightmap[x + 1][y])
        and (y - 1 < 0 or val < heightmap[x][y - 1])
        and (y + 1 >= COLS or val < heightmap[x][y + 1])
    )


low_points = [
    (x, y)
    for x, row in enumerate(heightmap)
    for y, val in enumerate(row)
    if is_low_point(val, x, y)
]


def basin_size(low_point: tuple[int, int]) -> int:
    def neighbors(x: int, y: int) -> list[tuple[int, int]]:
        result = []
        if x - 1 >= 0:
            result.append((x - 1, y))
        if x + 1 < ROWS:
            result.append((x + 1, y))
        if y - 1 >= 0:
            result.append((x, y - 1))
        if y + 1 < COLS:
            result.append((x, y + 1))
        return result

    visited = {low_point}
    q: deque[tuple[int, int]] = deque()
    q.append(low_point)
    while q:
        px, py = q.popleft()
        for n in neighbors(px, py):
            nx, ny = n
            if n not in visited and heightmap[nx][ny] < 9:
                visited.add(n)
                q.append(n)

    return len(visited)


basin_sizes = [basin_size(p) for p in low_points]

risk_level = sum((heightmap[x][y] + 1 for x, y in low_points))
print("Part 1:", risk_level)

three_largest_basins_product = math.prod(islice(sorted(basin_sizes, reverse=True), 3))
print("Part 2:", three_largest_basins_product)
