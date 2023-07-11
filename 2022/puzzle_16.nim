import std/deques
import std/hashes
import std/heapqueue
import std/sequtils
import std/sets
import std/strscans
import std/strutils
import std/sugar
import std/tables

const LINE_PATTERN = "Valve $w has flow rate=$i; $+"

type
    Valve = object
        name: string
        rate: int
        tunnels: seq[string]

let scan = collect:
    for line in stdin.lines:
        let (success, name, rate, rest) = line.scanTuple(LINE_PATTERN)
        assert success
        Valve(
            name: name,
            rate: rate,
            tunnels: rest.split(' ')[4..^1].toSeq.mapIt(
                it.strip(chars = {','})
            ),
        )

type
    Room = ref object
        valve: Valve
        dists: Table[string, int]

func hash(r: Room): Hash =
    hash(r.valve.name)

# Store metadata to easily traverse between rooms and get access to information.
let rooms = scan.map((x) => (x.name, Room(valve: x))).toTable

# Rooms that are worth traversing to because they can release pressure.
let valveRooms = rooms.values.toSeq.filter((x) => x.valve.rate > 0)

func shortestDistances(rooms: Table[string, Room], src: string): Table[string, int] =
    var hq = [(0, src)].toHeapQueue
    result[src] = 0

    while hq.len != 0:
        let (dist, cur) = hq.pop()
        for neighbor in rooms[cur].valve.tunnels:
            let newDist = dist + 1
            if newDist < result.getOrDefault(neighbor, int.high):
                result[neighbor] = newDist
                hq.push((newDist, neighbor))

# Compute distances from rooms that can release pressure, and don't worry about
# pruning out rooms that have a flow rate of 0.
for room in valveRooms:
    room.dists = rooms.shortestDistances(room.valve.name)

const
    START_LOCATION = "AA"
    TIME_PART1 = 30

# The start room has a flow rate of 0, so compute distances to other rooms.
let start = rooms[START_LOCATION]
start.dists = rooms.shortestDistances(start.valve.name)

type State = ref object
    room: Room
    timeLeft: int
    pressureReleased: int
    visited: HashSet[Room]

iterator states(s: State, valves: seq[Room]): State =
    for next in valves:
        if s.visited.contains(next):
            continue
        let timeLeft = s.timeLeft - s.room.dists[next.valve.name] - 1
        if timeLeft <= 0:
            continue

        let newState = State(
            room: next,
            timeLeft: timeLeft,
            pressureReleased: s.pressureReleased + next.valve.rate * timeLeft,
            visited: s.visited,
        )
        newState.visited.incl(next)
        yield newState

func pressuresReleased(
    start: Room,
    timeRemaining: int,
    valves: seq[Room],
): Table[HashSet[Room], int] =
    var q = [State(room: start, timeLeft: timeRemaining)].toDeque
    while q.len != 0:
        let cur = q.popFirst()
        for next in cur.states(valves):
            result[next.visited] = max(
                result.getorDefault(next.visited, 0),
                next.pressureReleased,
            )
            q.addLast(next)

echo "Part 1: ", max(
    pressuresReleased(
        start,
        TIME_PART1,
        valveRooms
    ).values.toSeq
)

const TIME_PART2 = 26

let releasePaths = pressuresReleased(start, TIME_PART2, valveRooms)
let pairedRelease = collect:
    for soloValves, soloPressure in releasePaths:
        for elephantValves, elephantPressure in releasePaths:
            if disjoint(soloValves, elephantValves):
                soloPressure + elephantPressure

echo "Part 2: ", max(pairedRelease)
