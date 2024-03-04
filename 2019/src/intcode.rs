use std::convert::From;
use std::io;

pub fn parse_program(input: impl io::Read) -> Vec<i32> {
    io::read_to_string(input)
        .unwrap()
        .trim()
        .split(',')
        .map(|x| x.parse().unwrap())
        .collect()
}

const INSTRUCTION_LEN: usize = 4;

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

fn extract_parameters(instruction: &[i32]) -> (usize, usize, usize) {
    (
        usize::try_from(instruction[1]).unwrap(),
        usize::try_from(instruction[2]).unwrap(),
        usize::try_from(instruction[3]).unwrap(),
    )
}

pub struct Computer {
    pub memory: Vec<i32>,
}

impl Computer {
    pub fn run(&mut self) {
        let mut pc: usize = 0;
        loop {
            match Opcode::from(self.memory[pc]) {
                Opcode::Add => {
                    let (addr1, addr2, dst) = extract_parameters(&self.memory[pc..]);
                    self.memory[dst] = self.memory[addr1] + self.memory[addr2];
                }
                Opcode::Multiply => {
                    let (addr1, addr2, dst) = extract_parameters(&self.memory[pc..]);
                    self.memory[dst] = self.memory[addr1] * self.memory[addr2];
                }
                Opcode::Halt => break,
            }

            pc += INSTRUCTION_LEN;
        }
    }
}
