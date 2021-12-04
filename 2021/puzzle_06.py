from collections import Counter
import fileinput
from itertools import chain

DAYS = (
    80,
    256,
)

NEW_TIMER = 8
RESET_TIMER = 6

# Parse
lantern_fish = [
    int(x)
    for x in chain.from_iterable(line.rstrip().split(",") for line in fileinput.input())
]

# Init
population: dict[int, int] = Counter(lantern_fish)
population_per_day = {}

# Main
for day in range(DAYS[-1]):
    new_population = {}
    for i in range(NEW_TIMER + 1):
        new_population[i % (NEW_TIMER + 1)] = population[(i + 1) % (NEW_TIMER + 1)]
    new_population[RESET_TIMER] += population[0]

    population = new_population
    population_per_day[day] = sum(population.values())

# Result
for day in DAYS:
    print(f"{day}: {population_per_day[day - 1]}")
