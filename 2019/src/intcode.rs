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

enum Instruction {
    Add(usize, usize, usize),
    Multiply(usize, usize, usize),
    Halt,
}

pub struct Computer {
    pub memory: Vec<i32>,
    ip: usize,
}

impl Computer {
    pub fn new(program: &[i32]) -> Self {
        Self {
            memory: program.to_vec(),
            ip: 0,
        }
    }

    fn fetch_instruction(&self, memory: &[i32]) -> Instruction {
        let opcode = memory[0];
        match opcode {
            1 => Instruction::Add(
                usize::try_from(memory[1]).unwrap(),
                usize::try_from(memory[2]).unwrap(),
                usize::try_from(memory[3]).unwrap(),
            ),
            2 => Instruction::Multiply(
                usize::try_from(memory[1]).unwrap(),
                usize::try_from(memory[2]).unwrap(),
                usize::try_from(memory[3]).unwrap(),
            ),
            99 => Instruction::Halt,
            _ => unreachable!(),
        }
    }

    pub fn run(&mut self) {
        loop {
            let instruction = self.fetch_instruction(&self.memory[self.ip..]);
            match instruction {
                Instruction::Add(addr1, addr2, dst) => {
                    self.memory[dst] = self.memory[addr1] + self.memory[addr2];
                    self.ip += INSTRUCTION_LEN;
                }
                Instruction::Multiply(addr1, addr2, dst) => {
                    self.memory[dst] = self.memory[addr1] * self.memory[addr2];
                    self.ip += INSTRUCTION_LEN;
                }
                Instruction::Halt => break,
            }
        }
    }
}
