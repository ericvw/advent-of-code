use std::collections::BinaryHeap;
use std::collections::HashMap;
use std::io;

use aoc2019::grid::Point;
use aoc2019::num;

#[derive(Ord, PartialOrd, Eq, PartialEq)]
struct AsteroidMetadata {
    loc: Point,
    distance: u32,
}

fn gcd(a: i32, b: i32) -> i32 {
    num::gcd(a.into(), b.into()).try_into().unwrap()
}

fn distances_from(
    monitoring_station: Point,
    asteroids: &[Point],
) -> HashMap<Point, Vec<AsteroidMetadata>> {
    let mut result: HashMap<Point, Vec<AsteroidMetadata>> = HashMap::new();

    for &a in asteroids {
        if a == monitoring_station {
            continue;
        }

        let delta = a - monitoring_station;
        let largest_factor = gcd(delta.x, delta.y);

        result
            .entry(Point {
                x: delta.x / largest_factor,
                y: delta.y / largest_factor,
            })
            .or_default()
            .push(AsteroidMetadata {
                loc: a,
                distance: monitoring_station.manhattan_distance(a),
            });
    }

    result
}

fn vaporize_until(asteroids: &HashMap<Point, Vec<AsteroidMetadata>>, count: u32) -> Point {
    let mut visible: HashMap<_, _> = asteroids
        .iter()
        .map(|(k, v)| (k, v.iter().collect::<BinaryHeap<&AsteroidMetadata>>()))
        .collect();

    let mut vaporization_order: Vec<_> = asteroids.keys().collect();

    // XXX: Note these are vectors (i.e., (dx, dy)) of the asteroids relative to the monitoring
    //      station. We reverse the arguments to atan2() from atan2(dy, dx) to atan2(dx, dy) to
    //      achieve a 90°CCW rotation and a vertical flip of the coordiante system. Sorting by the
    //      reversed arguments achieves a CCW sweep. To get a CW sweep, we reverse the order.
    vaporization_order.sort_by(|a, b| {
        f64::from(a.x)
            .atan2(f64::from(a.y))
            .total_cmp(&f64::from(b.x).atan2(f64::from(b.y)))
    });
    vaporization_order.reverse();

    let mut result: Point = Default::default();
    let mut i = 0;
    let count = usize::try_from(count).unwrap();
    while i < count {
        result = match visible
            .get_mut(vaporization_order[i % vaporization_order.len()])
            .unwrap()
            .pop()
        {
            Some(a) => a.loc,
            None => continue,
        };
        i += 1;
    }

    result
}

fn main() {
    // XXX: Note that y-coordinate is from the top, and x-coordinate is from the left.
    let mut asteroids = vec![];
    for (y, row) in io::stdin().lines().map(|line| line.unwrap()).enumerate() {
        for (x, c) in row.chars().enumerate() {
            if c == '#' {
                asteroids.push(Point {
                    x: i32::try_from(x).unwrap(),
                    y: i32::try_from(y).unwrap(),
                });
            }
        }
    }

    let dists_from_station = asteroids
        .iter()
        .map(|&loc| (loc, distances_from(loc, &asteroids)))
        .max_by(|a, b| a.1.len().cmp(&b.1.len()))
        .unwrap()
        .1;

    println!("Part 1: {}", dists_from_station.len());

    const BETTED_ASTEROID_VAPORIZED: u32 = 200;

    let asteroid = vaporize_until(&dists_from_station, BETTED_ASTEROID_VAPORIZED);

    println!("Part 2: {}", asteroid.x * 100 + asteroid.y);
}
