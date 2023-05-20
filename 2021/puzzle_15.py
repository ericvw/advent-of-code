import fileinput
import heapq
import sys
from typing import Generator

# Parse
cavern = [list(map(int, line.rstrip())) for line in fileinput.input()]

# Init
CAVERN_ROWS = len(cavern)
CAVERN_COLS = len(cavern[0])


# Main
def calculate_min_risk(
    cavern: list[list[int]], start: tuple[int, int], end: tuple[int, int]
) -> int:
    rows = len(cavern)
    cols = len(cavern[0])

    def neighbors(x: int, y: int) -> Generator[tuple[int, int], None, None]:
        if x - 1 >= 0:
            yield (x - 1, y)
        if x + 1 < rows:
            yield (x + 1, y)
        if y - 1 >= 0:
            yield (x, y - 1)
        if y + 1 < cols:
            yield (x, y + 1)

    cavern_map = {(x, y): cavern[x][y] for x in range(rows) for y in range(cols)}
    risks = {xy: sys.maxsize for xy in cavern_map.keys()}
    # XXX: Don't count the starting position.  Only positions entered.
    risks[start] = 0

    visited = set()
    pq = [(risks[start], start)]
    while pq:
        risk, cur = heapq.heappop(pq)
        visited.add(cur)

        if cur == end:
            break

        for unvisited_neighbor in filter(lambda xy: xy not in visited, neighbors(*cur)):
            new_risk = risk + cavern_map[unvisited_neighbor]
            if new_risk < risks[unvisited_neighbor]:
                risks[unvisited_neighbor] = new_risk
                heapq.heappush(pq, (new_risk, unvisited_neighbor))

    return risks[end]


def expand_cave(cavern: list[list[int]], factor: int) -> list[list[int]]:
    rows = len(cavern)
    cols = len(cavern[0])

    result = [[-1] * (cols * factor) for _ in range(rows * factor)]
    for row_factor in range(factor):
        for col_factor in range(factor):
            for x in range(rows):
                for y in range(cols):
                    r = rows * row_factor + x
                    c = cols * col_factor + y
                    result[r][c] = 1 + (
                        (cavern[x][y] + row_factor + col_factor) - 1
                    ) % (10 - 1)
    return result


risk = calculate_min_risk(cavern, (0, 0), (CAVERN_ROWS - 1, CAVERN_COLS - 1))
print("Part 1:", risk)

risk_5x = calculate_min_risk(
    expand_cave(cavern, 5), (0, 0), ((CAVERN_ROWS * 5) - 1, (CAVERN_COLS * 5) - 1)
)
print("Part 2:", risk_5x)
