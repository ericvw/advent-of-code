use std::io;

use aoc2019::intcode;

fn main() {
    let diagnostic_program = intcode::parse_program(io::stdin());

    println!(
        "Part 1: {}",
        intcode::Computer::new(&diagnostic_program, &[1])
            .run()
            .unwrap()
    );
    println!(
        "Part 2: {}",
        intcode::Computer::new(&diagnostic_program, &[5])
            .run()
            .unwrap()
    );
}
