import fileinput

# Parse
course = list(
    (direction, int(value))
    for direction, value in (line.rstrip().split() for line in fileinput.input())
)

# Init
horizontal = 0
part1_depth = 0
part2_depth = 0
aim = 0

# Main
for direction, value in course:
    if direction == "forward":
        horizontal += value
        part2_depth += aim * value
    elif direction == "down":
        part1_depth += value
        aim += value
    elif direction == "up":
        part1_depth -= value
        aim -= value

assert part1_depth == aim

# Result
print(f"Part 1: {horizontal * part1_depth}")
print(f"Part 2: {horizontal * part2_depth}")
