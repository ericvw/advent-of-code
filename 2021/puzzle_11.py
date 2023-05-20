from collections import deque
import fileinput
from itertools import product
from typing import Iterable

# Parse
octos = [list(map(int, line.rstrip())) for line in fileinput.input()]

# Init
MAX_ENERGY = 9
ROWS = len(octos)
COLS = len(octos[0])
N_OCTOS = ROWS * COLS


# Main
def neighbors(x: int, y: int) -> Iterable[tuple[int, int]]:
    x_coords = [x]
    y_coords = [y]
    if x - 1 >= 0:
        x_coords.append(x - 1)
    if x + 1 < ROWS:
        x_coords.append(x + 1)
    if y - 1 >= 0:
        y_coords.append(y - 1)
    if y + 1 < COLS:
        y_coords.append(y + 1)
    return filter(lambda xy: xy != (x, y), product(x_coords, y_coords))


def flashes_per_step(octos: list[list[int]]) -> int:
    flashed_to_spread: deque[tuple[int, int]] = deque()
    for x, row in enumerate(octos):
        for y, val in enumerate(row):
            octos[x][y] += 1
            if octos[x][y] > MAX_ENERGY:
                octos[x][y] = 0
                flashed_to_spread.append((x, y))

    flashed = set(flashed_to_spread)
    while flashed_to_spread:
        o = flashed_to_spread.popleft()
        for n in neighbors(*o):
            nx, ny = n
            if n in flashed:
                continue
            octos[nx][ny] += 1
            if octos[nx][ny] > MAX_ENERGY:
                octos[nx][ny] = 0
                flashed_to_spread.append(n)
                flashed.add(n)

    return len(flashed)


step = 0
flashes = 0
for i in range(100):
    step += 1
    flashes += flashes_per_step(octos)

while True:
    step += 1
    if flashes_per_step(octos) == N_OCTOS:
        break

print("Part 1:", flashes)
print("Part 2:", step)
