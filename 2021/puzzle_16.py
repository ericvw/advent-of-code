from enum import IntEnum
import fileinput
from io import StringIO
from math import prod

# Parse
hex_tx = fileinput.input().readline().rstrip()
# XXX: bin() omits leading zeros.
binary_tx = bin(int(hex_tx, 16))[2:].zfill(len(hex_tx) * 4)


# Init
class TypeID(IntEnum):
    SUM = 0
    PROD = 1
    MIN = 2
    MAX = 3
    LITERAL = 4
    GT = 5
    LT = 6
    EQ = 7


class LengthTypeID(IntEnum):
    TOTAL_LENGTH = 0
    NUMBER_OF_SUBPACKETS = 1


# Main
def parse_literal(pkt: StringIO) -> int:
    groups = []
    last_group = False
    while not last_group:
        last_group = int(pkt.read(1), 2) == 0
        groups.append(pkt.read(4))
    return int("".join(groups), 2)


def extract_operator_packets(pkt: StringIO) -> list[int]:
    packets = []

    length_typeid = int(pkt.read(1), 2)
    if length_typeid == LengthTypeID.TOTAL_LENGTH:
        length = int(pkt.read(15), 2)
        end_pos = pkt.tell() + length
        while pkt.tell() != end_pos:
            packets.append(parse_packet(pkt))
    elif length_typeid == LengthTypeID.NUMBER_OF_SUBPACKETS:
        n_pkts = int(pkt.read(11), 2)
        for _ in range(n_pkts):
            packets.append(parse_packet(pkt))
    else:
        assert False, "Unknown lenght type ID!"

    return packets


def parse_packet(pkt: StringIO) -> int:
    global version_sum
    # Header
    version = int(pkt.read(3), 2)
    version_sum += version
    typeid = int(pkt.read(3), 2)

    if typeid == TypeID.LITERAL:
        return parse_literal(pkt)

    packets = extract_operator_packets(pkt)
    if typeid == TypeID.SUM:
        return sum(packets)
    elif typeid == TypeID.PROD:
        return prod(packets)
    elif typeid == TypeID.MIN:
        return min(packets)
    elif typeid == TypeID.MAX:
        return max(packets)
    elif typeid == TypeID.GT:
        assert len(packets) == 2
        return int(packets[0] > packets[1])
    elif typeid == TypeID.LT:
        assert len(packets) == 2
        return int(packets[0] < packets[1])
    elif typeid == TypeID.EQ:
        assert len(packets) == 2
        return int(packets[0] == packets[1])
    # XXX: Should never hit this!
    assert False


version_sum = 0
value = parse_packet(StringIO(binary_tx))

# Result 1
print(f"Sum of all version numbers: {version_sum}")

# Result 2
print(f"Transmission value: {value}")
