from collections import Counter
import fileinput

# Parse
lines = [
    tuple(
        tuple(int(c) for c in point.split(",")) for point in line.rstrip().split("->")
    )
    for line in fileinput.input()
]

# Normalize
lines = [
    ((x2, y2), (x1, y1)) if x2 < x1 or y2 < y1 else ((x1, y1), (x2, y2))
    for (x1, y1), (x2, y2) in lines
]

# Main
counter_non_diag: Counter[tuple[int, int]] = Counter()
counter_diag: Counter[tuple[int, int]] = Counter()
for (x1, y1), (x2, y2) in lines:
    if x1 == x2:
        counter_non_diag.update((x1, y) for y in range(y1, y2 + 1))
    elif y1 == y2:
        counter_non_diag.update((x, y1) for x in range(x1, x2 + 1))
    else:
        # XXX: Renormalize for diagonals to keep one dimension monotonic.
        if x2 < x1:
            x1, x2 = x2, x1
            y1, y2 = y2, y1
        y_direction = -1 if y2 < y1 else 1
        counter_diag.update(
            (x1 + i, y1 + (i * y_direction)) for i in range(x2 + 1 - x1)
        )

overlap_non_diag = sum(1 for point, count in counter_non_diag.items() if count > 1)
print("Part 1:", overlap_non_diag)

counter_diag.update(counter_non_diag.elements())
overlapping = sum(1 for point, count in counter_diag.items() if count > 1)
print("Part 2:", overlapping)
