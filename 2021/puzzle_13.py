import fileinput

# Parse
puzzle_input = fileinput.input()

MAX_X = 0
MAX_Y = 0
dots = set()
for line in puzzle_input:
    line = line.rstrip()
    if not line:
        break
    x, y = map(int, line.split(","))
    MAX_X = max(x, MAX_X)
    MAX_Y = max(y, MAX_Y)
    dots.add((x, y))

folds = []
for line in puzzle_input:
    axis, val = line.rstrip().split(" ")[-1].split("=")
    folds.append((axis, int(val)))

# Main
n_dots_per_fold = []
for axis, fold in folds:
    if axis == "x":
        # Fold left.
        for dot in list(filter(lambda xy: xy[0] >= fold, dots)):
            dots.remove(dot)
            x, y = dot
            dots.add((2 * fold - x, y))
        MAX_X = fold
    elif axis == "y":
        # Fold up.
        for dot in list(filter(lambda xy: xy[1] >= fold, dots)):
            dots.remove(dot)
            x, y = dot
            dots.add((x, (2 * fold) - y))
        MAX_Y = fold
    else:
        assert False, "Axis unrecognized: {axis}"

    n_dots_per_fold.append(len(dots))

# Result 1
print(f"Dots visible after first fold: {n_dots_per_fold[0]}")

# Result 2
paper = [[" "] * (MAX_X + 1) for _ in range(MAX_Y + 1)]
for x, y in dots:
    paper[y][x] = "#"
print("\n".join("".join(row) for row in paper))
