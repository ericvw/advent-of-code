import fileinput
from itertools import chain
import math
import statistics

# Parse
crab_positions = [
    int(x)
    for x in chain.from_iterable(line.rstrip().split(",") for line in fileinput.input())
]

# Main

# Part 1
median = int(statistics.median(crab_positions))
deltas_to_align = [abs(p - median) for p in crab_positions]

# Result 1
print(f"Fuel spent for part 1: {sum(deltas_to_align)}")

# Part 2
mean = statistics.mean(crab_positions)
means = (math.ceil(mean), math.floor(mean))
min_fuel_spent = min(
    sum((d * (d + 1) // 2 for d in (abs(c - m) for c in crab_positions))) for m in means
)

# Result 2
print(f"Fuel spent for part 2: {min_fuel_spent}")
