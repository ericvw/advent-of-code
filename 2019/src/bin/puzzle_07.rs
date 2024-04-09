use std::io;

use aoc2019::intcode;

fn run_amplifier_loop(program: &[i64], phase_settings: &[i64]) -> i64 {
    let mut amplifiers: Vec<_> = phase_settings
        .iter()
        .map(|&phase_setting| intcode::Computer::new(program, &[phase_setting]))
        .collect();

    let mut signal = 0;

    'feedback_loop: loop {
        for a in &mut amplifiers {
            a.input.push_back(signal);
            signal = match a.run() {
                intcode::State::Output(x) => x,
                intcode::State::Halt => break 'feedback_loop,
            };
        }
    }

    signal
}

fn main() {
    let amplifier_controller_program = intcode::parse_program(io::stdin());

    println!(
        "Part 1: {}",
        aoc2019::iter::permutation(&[0, 1, 2, 3, 4])
            .map(|x| run_amplifier_loop(&amplifier_controller_program, &x))
            .max()
            .unwrap()
    );

    println!(
        "Part 2: {}",
        aoc2019::iter::permutation(&[5, 6, 7, 8, 9])
            .map(|x| run_amplifier_loop(&amplifier_controller_program, &x))
            .max()
            .unwrap()
    );
}
