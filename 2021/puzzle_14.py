from collections import Counter
import fileinput
from itertools import pairwise
from typing import cast

# Parse
puzzle_input = fileinput.input()
polymer_template = puzzle_input.readline().rstrip()
puzzle_input.readline()
rules = dict(
    cast(tuple[str, str], tuple(line.rstrip().split(" -> "))) for line in puzzle_input
)

# Init
STEPS = (
    10,
    40,
)

elem_counts = Counter(polymer_template)
polymer_counts = Counter("".join(p) for p in pairwise(polymer_template))

counts_per_step = []

# Main
for _ in range(STEPS[-1]):
    step_counts: Counter[str] = Counter()
    for pair, count in polymer_counts.items():
        new_elem = rules[pair]
        step_counts[pair[0] + new_elem] += count
        step_counts[new_elem + pair[1]] += count
        elem_counts[new_elem] += count
    polymer_counts = step_counts
    counts_per_step.append(elem_counts.copy())

for i, s in enumerate(STEPS):
    counts = counts_per_step[s - 1].most_common()
    print(f"Part {i + 1}",  counts[0][1] - counts[-1][1])
