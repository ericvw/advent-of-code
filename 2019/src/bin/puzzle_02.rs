use std::io;
use std::ops;

use aoc2019::intcode;

fn run_program(prog: &[i32], addr1_val: i32, addr2_val: i32) -> i32 {
    let mut computer = intcode::Computer::new(prog);

    computer.memory[1] = addr1_val;
    computer.memory[2] = addr2_val;

    computer.run();

    computer.memory[0]
}

fn main() {
    let gravity_assist_program = intcode::parse_program(io::stdin());

    println!("Part 1: {}", run_program(&gravity_assist_program, 12, 2));

    const TARGET_OUTPUT: i32 = 19690720;
    const INPUT_RANGE: ops::RangeInclusive<i32> = 0..=99;

    let (noun, verb) = INPUT_RANGE
        .flat_map(|noun| INPUT_RANGE.map(move |verb| (noun, verb)))
        .find(|&(noun, verb)| run_program(&gravity_assist_program, noun, verb) == TARGET_OUTPUT)
        .unwrap();

    println!("Part 2: {}", 100 * noun + verb);
}
