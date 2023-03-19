import std/deques
import std/setutils
import std/strutils

let datastream = stdin.readAll().strip()

proc charsProcessed(buffer: string, markerSize: int): int =
    var marker: Deque[char]

    for idx, ch in datastream:
        if marker.len == markerSize:
            discard marker.popFirst

        marker.addLast(ch)
        inc(result)

        if marker.toSet().card == markerSize:
            break

const PACKET_MARKER_SIZE = 4
echo "Part 1: ", charsProcessed(datastream, PACKET_MARKER_SIZE)

const MESSAGE_MARKER_SIZE = 14
echo "Part 2: ", charsProcessed(datastream, MESSAGE_MARKER_SIZE)
