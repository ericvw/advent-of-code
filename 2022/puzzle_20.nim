import std/lists
import std/math
import std/sequtils
import std/strutils
import std/sugar

let encryptedFile = collect:
    for line in stdin.lines:
        line.parseInt()

# NOTE: Upstream `to*LinkedRing` functions to std/lists.
func toDoublyLinkedRing[T](elems: openArray[T]): DoublyLinkedRing[T] =
    for elem in elems.items:
        result.add(elem)

func moveForward(
    l: var DoublyLinkedRing[int],
    n: var DoublyLinkedNode[int],
    dist: int,
) =
    var cur = n
    for _ in 1 .. dist:
        cur = cur.next

    if cur == n:
        return

    l.remove(n)
    n.next = cur.next
    cur.next = n
    n.prev = cur
    n.next.prev = n

func moveBackward(
    l: var DoublyLinkedRing[int],
    n: var DoublyLinkedNode[int],
    dist: int,
) =
    var cur = n
    for _ in 1 .. dist:
        cur = cur.prev

    if cur == n:
        return

    l.remove(n)
    n.prev = cur.prev
    cur.prev = n
    n.next = cur
    n.prev.next = n

func mix(l: var DoublyLinkedRing[int], repeat: int) =
    var order = collect:
        for node in l.nodes:
            node

    for _ in 1 .. repeat:
        for n in order.mitems:
            let distance = abs(n.value) mod (order.len - 1)
            if n.value > 0:
                l.moveForward(n, distance)
            elif n.value < 0:
                l.moveBackward(n, distance)

const
    GROVE_COORDINATE_NUMBERS = [
        1000,
        2000,
        3000,
    ]

func groveCoordinate(start: DoublyLinkedNode[int], dist: int): int =
    var cur = start
    for _ in 1 .. dist:
        cur = cur.next
    cur.value

iterator groveCoordinates(l: DoublyLinkedRing[int]): int =
    let node0 = l.find(0)
    for x in GROVE_COORDINATE_NUMBERS:
        yield groveCoordinate(node0, x)

func decrypt(
    encrypted: seq[int],
    mixes: int = 1,
    decryptionKey = 1
): int =
    var l = encrypted.toDoublyLinkedRing()
    for v in l.mitems:
        v *= decryptionKey
    l.mix(mixes)
    sum(toSeq(groveCoordinates(l)))

echo "Part 1: ", encryptedFile.decrypt()
echo "Part 2: ", encryptedFile.decrypt(10, 811589153)
