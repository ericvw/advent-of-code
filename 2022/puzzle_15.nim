import std/packedsets
import std/sequtils
import std/strscans
import std/sugar

type
    Coordinate = object
        x, y: int

    SensorReading = object
        sensor: Coordinate
        beacon: Coordinate
        distance: int

func manhattan_distance(a, b: Coordinate): int =
    abs(b.x - a.x) + abs(b.y - a.y)

const LINE_PATTERN = "Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i"

let readings = collect:
    for line in stdin.lines:
        let (success, sensorX, sensorY, beaconX, beaconY) = scanTuple(line, LINE_PATTERN)
        assert success
        let
            s = Coordinate(x: sensorX, y: sensorY)
            b = Coordinate(x: beaconX, y: beaconY)
        SensorReading(sensor: s, beacon: b, distance: manhattan_distance(s, b))

func xCoordinatesWithinSensorRangeForY(
    readings: seq[SensorReading],
    y: int,
): PackedSet[int] =
    iterator inRangeXCoordinates(r: SensorReading, y: int): int =
        let yDistFromSensor = abs(y - r.sensor.y)
        # XXX: If computed x distance is negative, it's not in range so we clamp to 0.
        let xDistFromSensor = max(r.distance - yDistFromSensor, 0)
        for x in (r.sensor.x - xDistFromSensor)..(r.sensor.x + xDistFromSensor):
            yield x

    for r in readings:
        for x in inRangeXCoordinates(r, y):
            result.incl(x)

func nonBeaconPositionsCount(readings: seq[SensorReading], y: int): int =
    let xCoordinates = xCoordinatesWithinSensorRangeForY(readings, y)
    let beaconsOnY = readings
        .filter((r) => r.beacon.y == y)
        .map((r) => r.beacon.x)
        .toPackedSet
    return xCoordinates.len - beaconsOnY.len

const PART_1_Y_ROW = 2000000

echo "Part 1: ", nonBeaconPositionsCount(readings, PART_1_Y_ROW)

#[
Part 2 Explanation For Posterity

Brute-forcing 4M x 4M coordinates is an approach. However, I wanted to see if
there  was a way to reduce the search space.

Since the distress beacon sits outside the perimeter of all sensors, and we
know there is a uniquely single position, we need to find a location that sits
outside any pair of sensors.

Each sensor and distance creates a diamond. For a pair of diamonds, the
distress beacon location will be where they intersect. For each pair of
diamonds, there are 8 intersection points (see 'X's in ASCII diagram below).

         \ /
          X
         / \
      \ /   \
       X     \ /
      / \     X
     #   \   / \
 1  ### 4 \ /   \
   #####   X     \
  ####### / \     #
 ####S####   \   ###
  ####### \   \ #####
   #####   \   ###S###
 3  ### 2   \ / #####
     #       X   ###
      \     / \   #
       \   /   \ /
        \ /     X
         X     / \
        / \   /
           \ /
            X
           / \

Each edge of the diamond is made of the following equations:

    1. y =  x - (sx - d) + sy
    2. y =  x - (sx + d) + sy
    3. y = -x + (sx - d) + sy
    4. y = -x + (sx + d) + sy

Thus, we need the intersection of the following edges between two diamonds:

    1x3, 1x4, 2x3, 2x4, 3x1, 3x2, 4x1, 4x2

Solving for x and y for edge 1 of diamond s1 and edge 3 of diamond s2:

    1:   y =  x - (s1x - d1) + s1y
    3:   y = -x + (s2x - d2) + s2y

Simplifying:

    1: y =  x - s1d + s1y, where s1d = s1x - d1 (left-most x coordinate)
    3: y = -x + s2d + s2y, where s2d = s2x - d2 (left-most x coordinate)

Substituting and solving for x:

    x - s1d + s1y = -x + s2d + s2y
               2x = s1d - s1y + s2d + s2y
                x = (s1d - s1y + s2d + s2y)/2

Substituting x back into simplified equation 1:

    y = (s1d - s1y + s2d + s2y)/2 - s1d + s1y
    y = (s1d - s1y + s2d + s2y - 2*s1d + 2*s1y)/2
    y = (s2d + s2y - s1d + s1y)/2

Equations for x and y can be used for each edge intersection by varying s1d and
s2d as inputs:

    1x3: s1d = s1x - d1, s2d = s2x - d2
    1x4: s1d = s1x - d1, s2d = s2x + d2
    2x3: s1d = s1x + d1, s2d = s2x - d2
    2x4: s1d = s1x + d1, s2d = s2x + d2

To get the other 4 intersection points, we can swap the order of s1d and s2d.

Relearning linear algebra to get this point and writing this all down so I
don't forget took way longer than what it is going to take to code this up.
]#

const
    MIN_XY = 0
    MAX_XY = 4000000

let readingPairs: seq[(SensorReading, SensorReading)] = collect:
    for i, r1 in readings.pairs:
        for r2 in readings[i+1 .. ^1]:
            (r1, r2)

func intPt(s1d, s1y, s2d, s2y: int): Coordinate =
    return Coordinate(
        x: (s1d - s1y + s2d + s2y) div 2,
        y: (s2d + s2y - s1d + s1y) div 2,
    )

iterator intersect(
    s1: Coordinate,
    d1: int,
    s2: Coordinate,
    d2: int,
): Coordinate =
    iterator intPts(s1x, s1y, d1, s2x, s2y, d2: int): Coordinate =
        yield intPt(s1x - d1, s1y, s2x - d2, s2y)
        yield intPt(s1x - d1, s1y, s2x + d2, s2y)
        yield intPt(s1x + d1, s1y, s2x - d2, s2y)
        yield intPt(s1x + d1, s1y, s2x + d2, s2y)

    for xy in intPts(s1.x, s1.y, d1, s2.x, s2.y, d2):
        yield xy

    for xy in intPts(s2.x, s2.y, d2, s1.x, s1.y, d1):
        yield xy

let intersections = collect:
    for r1, r2 in readingPairs.items:
        # XXX: We use 'distance + 1' to intersect just outside each sensor's range.
        for xy in intersect(r1.sensor, r1.distance + 1, r2.sensor, r2.distance + 1):
            xy

let inRange = intersections.filterIt(
    it.x >= MIN_XY and
    it.x <= MAX_XY and
    it.y >= MIN_XY and
    it.y <= MAX_XY
)

let distressBeacon = inRange.filter(
    (ipt) => readings.allIt(manhattan_distance(it.sensor, ipt) > it.distance)
)[0]

func tuningFrequency(xy: Coordinate): int =
    xy.x * MAX_XY + xy.y

echo "Part 2: ", tuningFrequency(distressBeacon)
