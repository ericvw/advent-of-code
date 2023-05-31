from collections import deque
from copy import deepcopy
from enum import Enum
import fileinput
from itertools import repeat
from typing import Generator
from typing import Sequence

# Types
Coordinate = tuple[int, int]


class PixelType(Enum):
    DARK = "."
    LIGHT = "#"


# Constants
STEPS = (
    2,
    50,
)

PIXEL2BINARY = str.maketrans(f"{PixelType.DARK.value}{PixelType.LIGHT.value}", "01")

ALGORITHM_LENGTH = 512


# Functions
def submatrix_coordinates(row: int, col: int) -> Generator[Coordinate, None, None]:
    for r in range(row - 1, row + 2):
        for c in range(col - 1, col + 2):
            yield (r, c)


def pixel_for_coordinate(
    row: int,
    col: int,
    image: Sequence[Sequence[str]],
    infinite_pixel: PixelType,
) -> str:
    if row < 0 or row == len(image) or col < 0 or col == len(image[0]):
        return infinite_pixel.value
    return image[row][col]


def pixel2decimal(pixel: str) -> int:
    return int(pixel.translate(PIXEL2BINARY), 2)


def expand(image: deque[deque[str]], pixel: PixelType) -> None:
    for col in image:
        col.appendleft(pixel.value)
        col.append(pixel.value)
    image.appendleft(deque(repeat(pixel.value, len(image[0]))))
    image.append(deque(repeat(pixel.value, len(image[0]))))


def _enhance(
    image: deque[deque[str]],
    algorithm: Sequence[str],
    infinite_pixel: PixelType,
) -> deque[deque[str]]:
    expand(image, infinite_pixel)
    result = deepcopy(image)
    for r in range(len(image)):
        for c in range(len(image[0])):
            binary_pixel_value = "".join(
                pixel_for_coordinate(x, y, image, infinite_pixel)
                for x, y in submatrix_coordinates(r, c)
            )
            algo_idx = pixel2decimal(binary_pixel_value)
            result[r][c] = algorithm[algo_idx]

    return result


# Parse
stdin = fileinput.input()
input_algo = tuple(stdin.readline().rstrip())
assert len(input_algo) == ALGORITHM_LENGTH
stdin.readline()
input_image = list(list(line.rstrip()) for line in stdin)


# Main
def enhance(
    image: Sequence[Sequence[str]],
    algorithm: Sequence[str],
    steps: int = 1,
) -> Sequence[Sequence[str]]:
    img = deque(deque(col) for col in image)
    infinite_pixel = PixelType.DARK
    alternate_pixel = (
        algorithm[0] == PixelType.LIGHT.value and algorithm[-1] == PixelType.DARK.value
    )
    for _ in range(steps):
        img = _enhance(img, algorithm, infinite_pixel)
        if alternate_pixel:
            infinite_pixel = (
                PixelType.LIGHT if infinite_pixel == PixelType.DARK else PixelType.DARK
            )
    return img


def count_pixels(image: Sequence[Sequence[str]], pixel: PixelType) -> int:
    return sum(col.count(pixel.value) for col in image)


for i, step in enumerate(STEPS):
    lit_pixels = count_pixels(enhance(input_image, input_algo, step), PixelType.LIGHT)
    print(f"Part {i + 1}:", lit_pixels)
