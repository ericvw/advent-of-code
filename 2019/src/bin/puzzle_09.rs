use std::io;

use aoc2019::intcode;

fn execute_program(prog: &[i64], input: &[i64]) -> i64 {
    let mut output = 0;

    let mut comp = intcode::Computer::new(prog, input);
    loop {
        output = match comp.run() {
            intcode::State::Output(x) => x,
            intcode::State::Halt => break,
        };
    }

    output
}

fn main() {
    let boost_program = intcode::parse_program(io::stdin());

    println!("Part 1: {}", execute_program(&boost_program, &[1]));

    println!("Part 2: {}", execute_program(&boost_program, &[2]));
}
