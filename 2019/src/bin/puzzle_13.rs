use std::collections::HashMap;
use std::io;

use aoc2019::grid::Point;
use aoc2019::intcode;

#[derive(PartialEq)]
enum TileId {
    Empty = 0,
    Wall = 1,
    Block = 2,
    HorizontalPaddle = 3,
    Ball = 4,
}

impl From<i64> for TileId {
    fn from(v: i64) -> Self {
        match v {
            0 => TileId::Empty,
            1 => TileId::Wall,
            2 => TileId::Block,
            3 => TileId::HorizontalPaddle,
            4 => TileId::Ball,
            _ => unreachable!(),
        }
    }
}

#[derive(Default)]
struct Game {
    program: Vec<i64>,
    quarters: Option<i64>,
    pub screen: HashMap<Point, TileId>,
}

const SCORE_LOCATION: Point = Point { x: -1, y: 0 };

impl Game {
    fn play(&mut self) -> i64 {
        self.screen.clear();

        let mut comp = intcode::Computer::new(&self.program, &[]);
        if self.quarters.is_some() {
            comp.memory[0] = self.quarters.unwrap();
        }

        let mut output_buffer = vec![];
        let mut ball_x_pos = 0;
        let mut paddle_x_pos = 0;
        let mut score = 0;
        loop {
            match comp.run() {
                intcode::State::Output(x) => {
                    output_buffer.push(x);
                    if output_buffer.len() == 3 {
                        let x = output_buffer[0];
                        let y = output_buffer[1];
                        let tile_id = output_buffer[2];

                        let position = Point {
                            x: x.try_into().unwrap(),
                            y: y.try_into().unwrap(),
                        };

                        if position == SCORE_LOCATION {
                            score = output_buffer[2];
                        } else {
                            match tile_id.into() {
                                TileId::Ball => ball_x_pos = x,
                                TileId::HorizontalPaddle => paddle_x_pos = x,
                                _ => (),
                            }
                            self.screen.insert(position, tile_id.into());
                        }

                        output_buffer.clear();
                    }
                }
                intcode::State::AwaitInput => {
                    let joystick = (ball_x_pos - paddle_x_pos).signum();
                    comp.input.push_back(joystick);
                }
                intcode::State::Halt => break,
            }
        }

        self.quarters = None;
        score
    }

    fn insert_quarters(&mut self, count: i64) {
        self.quarters = Some(count);
    }
}

fn main() {
    let mut game = Game {
        program: intcode::parse_program(io::stdin()),
        ..Default::default()
    };

    game.play();

    println!(
        "Part 1: {}",
        game.screen
            .iter()
            .filter(|&(_, tile)| *tile == TileId::Block)
            .count()
    );

    game.insert_quarters(2);
    println!("Part 2: {}", game.play());
}
