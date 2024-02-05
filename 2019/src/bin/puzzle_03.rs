use std::collections::HashMap;
use std::collections::HashSet;
use std::convert::From;
use std::io;
use std::ops::Add;

#[derive(Copy, Clone)]
enum Direction {
    Up,
    Down,
    Left,
    Right,
}

impl From<char> for Direction {
    fn from(v: char) -> Self {
        match v {
            'U' => Direction::Up,
            'D' => Direction::Down,
            'L' => Direction::Left,
            'R' => Direction::Right,
            _ => unreachable!(),
        }
    }
}

struct Vector {
    direction: Direction,
    magnitude: u32,
}

#[derive(Copy, Clone, Hash, Eq, PartialEq)]
struct Coordinate(i32, i32);

impl Coordinate {
    fn manhattan_distance(&self, Coordinate(x, y): Coordinate) -> u32 {
        x.abs_diff(self.0) + y.abs_diff(self.1)
    }
}

impl Add for Coordinate {
    type Output = Self;

    fn add(self, other: Self) -> Self {
        Self(self.0 + other.0, self.1 + other.1)
    }
}

fn trace_path(path: &Vec<Vector>) -> HashMap<Coordinate, u32> {
    let mut trace = HashMap::new();

    let mut c = Coordinate(0, 0);
    let mut len = 0;

    for &Vector {
        direction,
        magnitude,
    } in path
    {
        let step = match direction {
            Direction::Up => Coordinate(0, 1),
            Direction::Down => Coordinate(0, -1),
            Direction::Left => Coordinate(-1, 0),
            Direction::Right => Coordinate(1, 0),
        };

        for _ in 0..magnitude {
            c = c + step;
            len += 1;
            trace.entry(c).or_insert(len);
        }
    }

    trace
}

fn main() {
    let wire_paths: Vec<Vec<Vector>> = io::stdin()
        .lines()
        .map(|line| line.unwrap())
        .map(|path| {
            path.split(',')
                .map(|s| Vector {
                    direction: Direction::from(s.as_bytes()[0] as char),
                    magnitude: s[1..].parse().unwrap(),
                })
                .collect()
        })
        .collect();

    assert!(wire_paths.len() == 2, "Only two wire paths expected!");

    let trace1 = trace_path(&wire_paths[0]);
    let trace2 = trace_path(&wire_paths[1]);

    let keys1: HashSet<_> = HashSet::from_iter(trace1.keys());
    let keys2: HashSet<_> = HashSet::from_iter(trace2.keys());

    let intersections = keys1.intersection(&keys2);

    println!(
        "Part 1: {}",
        intersections
            .clone()
            .map(|c| c.manhattan_distance(Coordinate(0, 0)))
            .min()
            .unwrap()
    );

    println!(
        "Part 2: {}",
        intersections
            .map(|c| trace1.get(c).unwrap() + trace2.get(c).unwrap())
            .min()
            .unwrap()
    );
}
