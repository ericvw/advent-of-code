use std::collections::VecDeque;
use std::io;

pub fn parse_program(input: impl io::Read) -> Vec<i64> {
    io::read_to_string(input)
        .unwrap()
        .trim()
        .split(',')
        .map(|x| x.parse().unwrap())
        .collect()
}

enum Parameter {
    Position(i64),
    Immediate(i64),
    Relative(i64),
}

enum Instruction {
    Add(Parameter, Parameter, Parameter),
    Multiply(Parameter, Parameter, Parameter),
    Input(Parameter),
    Output(Parameter),
    JumpIfTrue(Parameter, Parameter),
    JumpIfFalse(Parameter, Parameter),
    LessThan(Parameter, Parameter, Parameter),
    Equals(Parameter, Parameter, Parameter),
    RelativeBase(Parameter),
    Halt,
}

pub enum State {
    Halt,
    Output(i64),
}

pub struct Computer {
    pub memory: Vec<i64>,
    pub input: VecDeque<i64>,
    ip: usize,
    modes: i64,
    relative_base: isize,
}

impl Computer {
    fn opcode(inst: i64) -> i64 {
        inst % 100
    }

    fn param_modes(inst: i64) -> i64 {
        inst / 100
    }

    pub fn new(program: &[i64], input: &[i64]) -> Self {
        Self {
            memory: program.to_vec(),
            input: input.iter().copied().collect(),
            ip: 0,
            modes: 0,
            relative_base: 0,
        }
    }

    fn read(&mut self) -> i64 {
        let val = self.memory[self.ip];
        self.ip += 1;
        val
    }

    fn next_param_mode(&mut self) -> i64 {
        let val = self.modes % 10;
        self.modes /= 10;
        val
    }

    fn create_parameter(&mut self) -> Parameter {
        let param_mode = self.next_param_mode();
        match param_mode {
            0 => Parameter::Position(self.read()),
            1 => Parameter::Immediate(self.read()),
            2 => Parameter::Relative(self.read()),
            _ => unreachable!(),
        }
    }

    fn fetch_instruction(&mut self) -> Instruction {
        let inst = self.read();
        let opcode = Self::opcode(inst);
        self.modes = Self::param_modes(inst);
        match opcode {
            1 => Instruction::Add(
                self.create_parameter(),
                self.create_parameter(),
                self.create_parameter(),
            ),
            2 => Instruction::Multiply(
                self.create_parameter(),
                self.create_parameter(),
                self.create_parameter(),
            ),
            3 => Instruction::Input(self.create_parameter()),
            4 => Instruction::Output(self.create_parameter()),
            5 => Instruction::JumpIfTrue(self.create_parameter(), self.create_parameter()),
            6 => Instruction::JumpIfFalse(self.create_parameter(), self.create_parameter()),
            7 => Instruction::LessThan(
                self.create_parameter(),
                self.create_parameter(),
                self.create_parameter(),
            ),
            8 => Instruction::Equals(
                self.create_parameter(),
                self.create_parameter(),
                self.create_parameter(),
            ),
            9 => Instruction::RelativeBase(self.create_parameter()),
            99 => Instruction::Halt,
            _ => unreachable!(),
        }
    }

    fn value(&self, param: Parameter) -> i64 {
        match param {
            Parameter::Position(addr) => {
                let addr = usize::try_from(addr).unwrap();
                *self.memory.get(addr).unwrap_or(&0)
            }
            Parameter::Immediate(val) => val,
            Parameter::Relative(offset) => {
                let offset = isize::try_from(offset).unwrap();
                let addr = usize::try_from(offset + self.relative_base).unwrap();
                *self.memory.get(addr).unwrap_or(&0)
            }
        }
    }

    fn write(&mut self, param: Parameter, val: i64) {
        let dst = match param {
            Parameter::Position(addr) => usize::try_from(addr).unwrap(),
            Parameter::Immediate(_) => unreachable!(),
            Parameter::Relative(offset) => {
                let offset = isize::try_from(offset).unwrap();
                usize::try_from(offset + self.relative_base).unwrap()
            }
        };

        if dst >= self.memory.len() {
            self.memory.resize(dst + 1, 0);
        }

        self.memory[dst] = val;
    }

    fn jump(&mut self, new_ip: Parameter) {
        self.ip = usize::try_from(self.value(new_ip)).unwrap();
    }

    pub fn run(&mut self) -> State {
        loop {
            let instruction = self.fetch_instruction();
            match instruction {
                Instruction::Add(op1, op2, dst) => {
                    self.write(dst, self.value(op1) + self.value(op2));
                }
                Instruction::Multiply(op1, op2, dst) => {
                    self.write(dst, self.value(op1) * self.value(op2));
                }
                Instruction::Input(dst) => {
                    let val = self.input.pop_front().unwrap();
                    self.write(dst, val);
                }
                Instruction::Output(val) => return State::Output(self.value(val)),

                Instruction::JumpIfTrue(cond, new_ip) => {
                    if self.value(cond) != 0 {
                        self.jump(new_ip);
                    }
                }
                Instruction::JumpIfFalse(cond, new_ip) => {
                    if self.value(cond) == 0 {
                        self.jump(new_ip);
                    }
                }
                Instruction::LessThan(lhs, rhs, dst) => self.write(
                    dst,
                    if self.value(lhs) < self.value(rhs) {
                        1
                    } else {
                        0
                    },
                ),
                Instruction::Equals(lhs, rhs, dst) => self.write(
                    dst,
                    if self.value(lhs) == self.value(rhs) {
                        1
                    } else {
                        0
                    },
                ),
                Instruction::RelativeBase(offset) => {
                    let offset = isize::try_from(self.value(offset)).unwrap();
                    self.relative_base += offset
                }
                Instruction::Halt => return State::Halt,
            }
        }
    }
}
