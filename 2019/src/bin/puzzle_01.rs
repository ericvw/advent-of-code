use std::io;
use std::iter;

fn fuel_for_module(mass: u32) -> Option<u32> {
    (mass / 3).checked_sub(2)
}

fn fuel_for_module_and_fuel(mass: u32) -> u32 {
    iter::successors(fuel_for_module(mass), |&x| fuel_for_module(x)).sum()
}

fn main() {
    let masses: Vec<u32> = io::stdin()
        .lines()
        .map(|line| line.unwrap())
        .map(|x| x.parse().unwrap())
        .collect();

    println!(
        "Part 1: {}",
        masses
            .iter()
            .copied()
            .map(fuel_for_module)
            .map(|x| x.unwrap())
            .sum::<u32>()
    );

    println!(
        "Part 2: {}",
        masses
            .iter()
            .copied()
            .map(fuel_for_module_and_fuel)
            .sum::<u32>()
    );
}
