from collections import Counter
from collections import deque
import fileinput
from statistics import median

# Parse
nav_subsystem = [line.rstrip() for line in fileinput.input()]

# Init
BASE_CHUNKS = (
    ("(", ")"),
    ("[", "]"),
    ("{", "}"),
    ("<", ">"),
)

open2close = {k: v for k, v in BASE_CHUNKS}

CLOSING_CHARS = {v for k, v in BASE_CHUNKS}

illegal_char_score = {
    ")": 3,
    "]": 57,
    "}": 1197,
    ">": 25137,
}

completion_char_score = {
    ")": 1,
    "]": 2,
    "}": 3,
    ">": 4,
}

# Main
illegal_characters = []
completion_scores = []
for line in nav_subsystem:
    stack: deque[str] = deque()
    for char in line:
        if char in open2close:
            stack.append(char)
        elif open2close[stack.pop()] != char:
            # Corrupt line.
            illegal_characters.append(char)
            break
    else:
        # Incomplete line.
        completion_score = 0
        for open_char in reversed(stack):
            completion_score *= 5
            completion_score += completion_char_score[open2close[open_char]]
        completion_scores.append(completion_score)


# Result 1
error_score = sum(
    illegal_char_score[char] * count
    for char, count in Counter(illegal_characters).items()
)
print(f"Total syntax error score: {error_score}")

# Result 2
middle_completion_score = median(sorted(completion_scores))
print(f"Middle completion score: {middle_completion_score}")
