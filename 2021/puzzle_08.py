import fileinput
from typing import Sequence

# Parse
lines = [line.rstrip() for line in fileinput.input()]
entries = [
    tuple(
        (
            tuple(frozenset(s) for s in pattern.split(" "))
            for pattern in line.split(" | ")
        )
    )
    for line in lines
]

# Init
n_wires_to_digits = {
    2: 1,
    4: 4,
    3: 7,
    7: 8,
}


# Main
def create_signal_to_digit_mapping(
    signals: Sequence[frozenset[str]],
) -> dict[frozenset[str], int]:
    digit2signal = {
        n_wires_to_digits[len(s)]: s for s in signals if len(s) in n_wires_to_digits
    }

    wire6_digits = [s for s in signals if len(s) == 6]
    digit2signal[6] = next(s for s in wire6_digits if len(s & digit2signal[1]) == 1)
    digit2signal[9] = next(s for s in wire6_digits if len(s & digit2signal[4]) == 4)

    wire5_digits = [s for s in signals if len(s) == 5]
    digit2signal[2] = next(s for s in wire5_digits if len(s & digit2signal[4]) == 2)
    digit2signal[3] = next(s for s in wire5_digits if len(s & digit2signal[1]) == 2)
    digit2signal[5] = next(s for s in wire5_digits if len(s & digit2signal[6]) == 5)

    digit2signal[0] = next(s for s in wire6_digits if len(s & digit2signal[5]) == 4)

    return {v: k for k, v in digit2signal.items()}


unique_digit_count = 0
output_sum = 0
for signals, outputs in entries:
    unique_digit_count += sum(1 for x in outputs if len(x) in n_wires_to_digits)

    signal2digit = create_signal_to_digit_mapping(signals)
    o1, o2, o3, o4 = outputs
    output_sum += (
        1000 * signal2digit[o1]
        + 100 * signal2digit[o2]
        + 10 * signal2digit[o3]
        + signal2digit[o4]
    )


# Result 1
print(f"Occurrences of 1, 4, 7, or 8: {unique_digit_count}")
# Result 2
print(f"Output value sum: {output_sum}")
