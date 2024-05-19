use std::cmp::Ordering;
use std::io;

use aoc2019::num;

#[derive(Default, Clone, Copy)]
struct Vec3 {
    x: i32,
    y: i32,
    z: i32,
}

#[derive(Default, Clone, Copy)]
struct Moon {
    position: Vec3,
    velocity: Vec3,
}

fn velocity_delta(pos1: i32, pos2: i32) -> i32 {
    match pos1.cmp(&pos2) {
        Ordering::Less => 1,
        Ordering::Equal => 0,
        Ordering::Greater => -1,
    }
}

impl Moon {
    fn apply_gravity(&mut self, other: &Moon) {
        self.velocity.x += velocity_delta(self.position.x, other.position.x);
        self.velocity.y += velocity_delta(self.position.y, other.position.y);
        self.velocity.z += velocity_delta(self.position.z, other.position.z);
    }

    fn apply_velocity(&mut self) {
        self.position.x += self.velocity.x;
        self.position.y += self.velocity.y;
        self.position.z += self.velocity.z;
    }

    fn potential_energy(&self) -> i32 {
        self.position.x.abs() + self.position.y.abs() + self.position.z.abs()
    }

    fn kinectic_energy(&self) -> i32 {
        self.velocity.x.abs() + self.velocity.y.abs() + self.velocity.z.abs()
    }
    fn energy(&self) -> i32 {
        self.potential_energy() * self.kinectic_energy()
    }
}

fn step(moons: &mut [Moon], index_pairs: &[(usize, usize)]) {
    for &(i, j) in index_pairs {
        let (left, right) = moons.split_at_mut(j);
        left[i].apply_gravity(&right[0]);
        right[0].apply_gravity(&left[i]);
    }

    for moon in moons {
        moon.apply_velocity();
    }
}

fn index_pairs(size: usize) -> Vec<(usize, usize)> {
    let indices = Vec::from_iter(0..size);
    let mut result = Vec::new();

    for i in 0..indices.len() - 1 {
        for j in i + 1..indices.len() {
            result.push((indices[i], indices[j]));
        }
    }

    result
}

fn simulate_motion(mut moons: Vec<Moon>, steps: usize) -> Vec<Moon> {
    let index_pairs = index_pairs(moons.len());
    for _ in 0..steps {
        step(&mut moons, &index_pairs);
    }
    moons
}

fn total_system_energy(moons: &[Moon]) -> i32 {
    moons.iter().map(|m| m.energy()).sum()
}

fn period_step_for_positions(positions: &[i32]) -> u64 {
    let index_pairs = index_pairs(positions.len());

    let mut positions = positions.to_vec();
    let mut velocities = vec![0; positions.len()];

    let init_positions = positions.clone();
    let init_velocities = velocities.clone();

    let mut steps = 0;
    loop {
        for &(i, j) in &index_pairs {
            velocities[i] += velocity_delta(positions[i], positions[j]);
            velocities[j] += velocity_delta(positions[j], positions[i]);
        }

        for (i, pos) in positions.iter_mut().enumerate() {
            *pos += velocities[i];
        }

        steps += 1;
        if velocities == init_velocities && positions == init_positions {
            break;
        }
    }
    steps
}

fn lcm(a: u64, b: u64) -> u64 {
    a * b / num::gcd(a.try_into().unwrap(), b.try_into().unwrap())
}

fn steps_until_repeating_state(moons: &[Moon]) -> u64 {
    let x_repeat_steps =
        period_step_for_positions(&moons.iter().map(|m| m.position.x).collect::<Vec<_>>());
    let y_repeat_steps =
        period_step_for_positions(&moons.iter().map(|m| m.position.y).collect::<Vec<_>>());
    let z_repeat_steps =
        period_step_for_positions(&moons.iter().map(|m| m.position.z).collect::<Vec<_>>());
    lcm(x_repeat_steps, lcm(y_repeat_steps, z_repeat_steps))
}

fn main() {
    let unparsed_moon_positions = io::stdin()
        .lines()
        .collect::<Result<Vec<String>, _>>()
        .unwrap();

    let moons: Vec<_> = unparsed_moon_positions
        .iter()
        .map(|s| &s[1..s.len() - 1])
        .map(|s| {
            s.split(", ")
                .map(|s| s[s.find('=').unwrap() + 1..].parse::<i32>().unwrap())
                .collect::<Vec<_>>()
        })
        .map(|coords| Moon {
            position: Vec3 {
                x: coords[0],
                y: coords[1],
                z: coords[2],
            },
            ..Default::default()
        })
        .collect();

    println!(
        "Part 1: {}",
        total_system_energy(&simulate_motion(moons.clone(), 1000))
    );

    println!("Part 2: {}", steps_until_repeating_state(&moons));
}
