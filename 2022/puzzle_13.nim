import std/algorithm
import std/enumerate
import std/math
import std/parseutils
import std/sequtils
import std/strutils
import std/sugar

type
    PacketKind = enum
        pkInt
        pkList

    Packet = ref object
        case kind: PacketKind
        of pkInt: val: int
        of pkList: packets: seq[Packet]

func isInt(self: Packet): bool {.inline.} =
    return self.kind == pkInt

func `$`(n: Packet): string =
    case n.kind
    of pkInt: result = $n.val
    of pkList:
        result = "[" & n.packets.mapIt($it).join(",") & "]"

proc parsePacket(s: string): Packet =
    var stack: seq[Packet]
    var i = 0
    while i < s.len:
        let c = s[i]
        var consumed = 1
        case c
        of '[':
            let listPacket = Packet(kind: pkList)
            if stack.len > 0:
                stack[^1].packets.add(listPacket)
            stack.add(listPacket)
        of ']':
            result = stack.pop()
        of ',':
            discard
        else:
            var intRes: int
            consumed = parseInt(s, intRes, i)
            stack[^1].packets.add(Packet(kind: pkInt, val: intRes))
        i += consumed

let distressSignal = collect:
    for line in stdin.lines:
        if line.len != 0:
            parsePacket(line)

let packetPairs = distressSignal.distribute(distressSignal.len div 2)

proc rightOrder(left, right: Packet): int =
    if left.isInt() and right.isInt():
        return cmp(left.val, right.val)
    elif left.isInt():
        return rightOrder(Packet(kind: pkList, packets: @[left]), right)
    elif right.isInt():
        return rightOrder(left, Packet(kind: pkList, packets: @[right]))

    let minLen = min(left.packets.len, right.packets.len)
    for i in 0 ..< minLen:
        let r = rightOrder(left.packets[i], right.packets[i])
        if r != 0:
            return r
    return left.packets.len - right.packets.len

let indicesOfPairsInOrder = collect:
    for i, pair in enumerate(1, packetPairs):
        if rightOrder(pair[0], pair[1]) < 0:
            i

echo "Part 1: ", sum(indicesOfPairsInOrder)

const
    DIVIDER_PACKET_INPUT = [
        "[[2]]",
        "[[6]]",
    ]

let dividerPackets = collect:
    for line in DIVIDER_PACKET_INPUT:
        parsePacket(line)

var allPackets = distressSignal & dividerPackets
allPackets.sort(rightOrder)
let dividerIndices = collect:
    for pkt in dividerPackets:
        binarySearch(allPackets, pkt, rightOrder) + 1

echo "Part 2: ", dividerIndices.foldl(a * b)
