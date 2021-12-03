import fileinput
from itertools import islice

# Parse
measurements = list(map(int, fileinput.input()))


# Main
def increases_per_window_size(measurements: list[int], window_size: int) -> int:
    prev_sum = sum(islice(measurements, window_size))
    increases = 0
    for i in range(0, len(measurements) - window_size):
        new_sum = prev_sum - measurements[i] + measurements[i + window_size]
        if new_sum > prev_sum:
            increases += 1
        prev_sum = new_sum

    return increases


# Result 1
print(
    f"Measurements largest than previous: {increases_per_window_size(measurements, 1)}"
)

# Result 2
print(
    f"3-Window sums larger than previous: {increases_per_window_size(measurements, 3)}"
)
