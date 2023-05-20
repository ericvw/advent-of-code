import fileinput

BOARD_SIZE = 5

# Parse
stdin = fileinput.input()
calls = list(map(int, stdin.readline().rstrip().split(",")))
stdin.readline()

boards = []
board: list[list[int]] = []
for line in stdin:
    line = line.rstrip()
    if not line:
        boards.append(board)
        board = []
        continue
    board.append(list(map(int, line.split())))
boards.append(board)

# Init
board_marks = {}
for i, board in enumerate(boards):
    marks: list[set[int]] = []
    marks.extend(set(board[r]) for r in range(BOARD_SIZE))
    marks.extend(set(board[r][c] for r in range(BOARD_SIZE)) for c in range(BOARD_SIZE))
    board_marks[i] = marks

winners = []

# Main
for call_idx, call in enumerate(calls):
    for board_idx in list(board_marks.keys()):
        marks = board_marks[board_idx]
        for row in marks:
            row.discard(call)
            if not row:
                winners.append((board_idx, call_idx))
                del board_marks[board_idx]
                break
            else:
                continue
        if len(board_marks) == 0:
            break
    else:
        continue
    break


# Result
def final_score(winner_idx: int, call_idx: int) -> int:
    winner = boards[winner_idx]
    winner_set = set(winner[r][c] for r in range(BOARD_SIZE) for c in range(BOARD_SIZE))
    call_set = set(calls[: call_idx + 1])
    unmarked_sum = sum(winner_set - call_set)
    return unmarked_sum * call


print("Part 1:", final_score(*winners[0]))
print("Part 2:", final_score(*winners[-1]))
