use std::convert::From;
use std::io;
use std::ops;

enum Opcode {
    Add = 1,
    Multiply = 2,
    Halt = 99,
}

impl From<i32> for Opcode {
    fn from(x: i32) -> Self {
        match x {
            1 => Opcode::Add,
            2 => Opcode::Multiply,
            99 => Opcode::Halt,
            _ => unreachable!(),
        }
    }
}

const INSTRUCTION_LEN: usize = 4;

fn extract_parameters(instruction: &[i32]) -> (usize, usize, usize) {
    (
        usize::try_from(instruction[1]).unwrap(),
        usize::try_from(instruction[2]).unwrap(),
        usize::try_from(instruction[3]).unwrap(),
    )
}

fn run_program(prog: &[i32], addr1_val: i32, addr2_val: i32) -> Vec<i32> {
    let mut prog = prog.to_vec();

    prog[1] = addr1_val;
    prog[2] = addr2_val;

    let mut idx: usize = 0;
    loop {
        match Opcode::from(prog[idx]) {
            Opcode::Add => {
                let (addr1, addr2, dst) = extract_parameters(&prog[idx..]);
                prog[dst] = prog[addr1] + prog[addr2];
            }
            Opcode::Multiply => {
                let (addr1, addr2, dst) = extract_parameters(&prog[idx..]);
                prog[dst] = prog[addr1] * prog[addr2];
            }
            Opcode::Halt => break,
        }

        idx += INSTRUCTION_LEN;
    }

    prog
}

fn main() {
    let intcode_prog: Vec<i32> = io::read_to_string(io::stdin())
        .unwrap()
        .trim()
        .split(',')
        .map(|x| x.parse().unwrap())
        .collect();

    println!("Part 1: {}", run_program(&intcode_prog, 12, 2)[0]);

    const TARGET_OUTPUT: i32 = 19690720;
    const INPUT_RANGE: ops::RangeInclusive<i32> = 0..=99;

    let (noun, verb) = INPUT_RANGE
        .flat_map(|noun| INPUT_RANGE.map(move |verb| (noun, verb)))
        .find(|&(noun, verb)| run_program(&intcode_prog, noun, verb)[0] == TARGET_OUTPUT)
        .unwrap();

    println!("Part 2: {}", 100 * noun + verb);
}
