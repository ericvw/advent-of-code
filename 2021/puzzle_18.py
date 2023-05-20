from __future__ import annotations

from dataclasses import dataclass
import fileinput
import functools
import itertools
import math
from typing import Any
from typing import Optional

# Parse
hw_list = [eval(line.rstrip()) for line in fileinput.input()]

# Init
EXPLODE_DEPTH = 4
SPLIT_THRESHOLD = 10


@dataclass
class Node:
    val: Optional[int] = None
    left: Optional[Node] = None
    right: Optional[Node] = None
    parent: Optional[Node] = None

    def __repr__(self) -> str:
        if self.val is not None:
            return str(self.val)
        else:
            return f"[{repr(self.left)},{repr(self.right)}]"


def list2tree(lst: Any, parent: Optional[Node] = None) -> Node:
    # XXX: Recursive types aren't supported in mypy; thus, 'Any'.
    n = Node(parent=parent)
    if type(lst) == int:
        n.val = lst
    else:
        left, right = lst
        n.left = list2tree(left, n)
        n.right = list2tree(right, n)
    return n


# Main
def rightmost_val(node: Node) -> Node:
    if node.right is not None:
        return rightmost_val(node.right)
    else:
        return node


def leftmost_val(node: Node) -> Node:
    if node.left is not None:
        return leftmost_val(node.left)
    else:
        return node


def add_left(node: Node, val: int) -> None:
    while node.parent is not None:
        if node is node.parent.right:
            assert node.parent.left is not None
            n = rightmost_val(node.parent.left)
            assert n.val is not None
            n.val += val
            break
        else:
            node = node.parent


def add_right(node: Node, val: int) -> None:
    while node.parent is not None:
        if node is node.parent.left:
            assert node.parent.right is not None
            n = leftmost_val(node.parent.right)
            assert n.val is not None
            n.val += val
            break
        else:
            node = node.parent


def explode(node: Node) -> None:
    assert node.left is not None
    lval = node.left.val
    assert node.right is not None
    rval = node.right.val
    node.val = 0
    node.left = None
    node.right = None
    assert lval is not None
    add_left(node, lval)
    assert rval is not None
    add_right(node, rval)


def split(node: Node) -> None:
    assert node.val is not None
    div = node.val / 2
    node.left = Node(parent=node, val=math.floor(div))
    node.right = Node(parent=node, val=math.ceil(div))
    node.val = None


def snailfish_explode(node: Optional[Node], depth: int = 0) -> bool:
    if node is None:
        return False

    if depth >= EXPLODE_DEPTH and node.val is None:
        explode(node)
        return True

    return snailfish_explode(node.left, depth + 1) or snailfish_explode(
        node.right, depth + 1
    )


def snailfish_split(node: Optional[Node]) -> bool:
    if node is None:
        return False

    if node.val is not None and node.val >= SPLIT_THRESHOLD:
        split(node)
        return True

    return snailfish_split(node.left) or snailfish_split(node.right)


def snailfish_reduce(root: Node) -> Node:
    while snailfish_explode(root) or snailfish_split(root):
        pass
    return root


def snailfish_add(lhs: Node, rhs: Node) -> Node:
    node = Node(left=lhs, right=rhs)
    lhs.parent = node
    rhs.parent = node
    result = snailfish_reduce(node)
    return result


def snailfish_magnitude(node: Node) -> int:
    if node.val is not None:
        return node.val
    assert node.left is not None
    assert node.right is not None
    return snailfish_magnitude(node.left) * 3 + snailfish_magnitude(node.right) * 2


snail_sum = functools.reduce(snailfish_add, map(list2tree, hw_list))
print("Part 1:", snailfish_magnitude(snail_sum))

max_magnitude = max(
    map(
        snailfish_magnitude,
        itertools.starmap(
            snailfish_add,
            (
                (list2tree(a), list2tree(b))
                for a, b in itertools.permutations(hw_list, 2)
            ),
        ),
    )
)
print("Part 2:", max_magnitude)
