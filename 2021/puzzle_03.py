from collections import Counter
import fileinput
from typing import Callable

# Parse
report = list(line.rstrip() for line in fileinput.input())


# Main
def compute_gamma_and_epsilon(report: list[str]) -> tuple[int, int]:
    transposed = list(zip(*report, strict=True))
    counters = list(map(Counter, transposed))

    gamma = ""
    epsilon = ""
    for c in counters:
        most_common, least_common = c.most_common()
        gamma += str(most_common[0])
        epsilon += str(least_common[0])

    return int(gamma, 2), int(epsilon, 2)


def extract_rating(
    report: list[str],
    preferred_bit_fn: Callable[[tuple[str, int], tuple[str, int]], str],
) -> int:
    candidates = report.copy()

    n_cols = len(candidates[0])
    for i in range(n_cols):
        transposed = list(zip(*candidates, strict=True))
        c = Counter(transposed[i])

        preferred_bit = preferred_bit_fn(*c.most_common())
        candidates = list(filter(lambda x: x[i] == preferred_bit, candidates))
        if len(candidates) == 1:
            break

    return int(candidates.pop(), 2)


gamma, epsilon = compute_gamma_and_epsilon(report)
print("Part 1:", gamma * epsilon)

oxygen_rating = extract_rating(report, lambda mc, lc: "1" if mc[1] == lc[1] else mc[0])
co2_rating = extract_rating(report, lambda mc, lc: "0" if mc[1] == lc[1] else lc[0])
print("Part 2:", oxygen_rating * co2_rating)
