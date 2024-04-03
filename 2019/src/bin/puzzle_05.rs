use std::io;

use aoc2019::intcode;

fn execute_diagnostic_program(prog: &[i32], input: &[i32]) -> i32 {
    let mut diagnostic_code = 0;

    let mut comp = intcode::Computer::new(prog, input);
    loop {
        diagnostic_code = match comp.run() {
            intcode::State::Output(x) => x,
            intcode::State::Halt => break,
        }
    }

    diagnostic_code
}

fn main() {
    let diagnostic_program = intcode::parse_program(io::stdin());

    println!(
        "Part 1: {}",
        execute_diagnostic_program(&diagnostic_program, &[1])
    );
    println!(
        "Part 2: {}",
        execute_diagnostic_program(&diagnostic_program, &[5])
    );
}
