import dataclasses
from dataclasses import dataclass
import fileinput
import functools
from itertools import cycle
from itertools import product


# Types
@dataclass(unsafe_hash=True)
class Player:
    position: int
    score: int = 0


# Functions
def move_forward(start: int, steps: int) -> int:
    return 1 + ((start + steps) - 1) % 10


# Parse
start_positions = tuple(int(line.split(":")[-1].strip()) for line in fileinput.input())


# Main
def practice_game(
    p1_start: int,
    p2_start: int,
    goal: int = 1000,
) -> tuple[tuple[int, ...], int]:
    die = cycle(range(1, 101))
    players = (Player(p1_start), Player(p2_start))
    roll_count = 0
    rolls = 3

    while True:
        for player in players:
            player.position = move_forward(
                player.position, sum(next(die) for i in range(rolls))
            )
            roll_count += rolls
            player.score += player.position
            if player.score >= goal:
                return (tuple(p.score for p in players), roll_count)


def real_game(
    p1_start: int,
    p2_start: int,
    goal: int = 21,
) -> tuple[int, ...]:
    players = (Player(p1_start), Player(p2_start))

    @functools.cache
    def count_wins(p1: Player, p2: Player) -> tuple[int, int]:
        p1_wins = 0
        p2_wins = 0
        for roll_sum in (sum(rolls) for rolls in product(range(1, 4), repeat=3)):
            p1_split = dataclasses.replace(p1)
            p1_split.position = move_forward(p1_split.position, roll_sum)
            p1_split.score += p1_split.position
            if p1_split.score >= goal:
                p1_wins += 1
            else:
                # XXX: Order is swapped because it is first argument's turn.
                p2_wins_split, p1_wins_split = count_wins(p2, p1_split)
                p1_wins += p1_wins_split
                p2_wins += p2_wins_split

        return (p1_wins, p2_wins)

    return count_wins(*players)


scores, roll_count = practice_game(*start_positions)
print("Part 1:", min(scores) * roll_count)

wins = real_game(*start_positions)
print("Part 2:", max(wins))
