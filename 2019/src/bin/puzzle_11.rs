use std::cmp;
use std::collections::HashMap;
use std::io;

use aoc2019::grid::Point;
use aoc2019::intcode;

#[derive(Copy, Clone)]
enum PanelColor {
    Black = 0,
    White = 1,
}

impl From<i64> for PanelColor {
    fn from(v: i64) -> Self {
        match v {
            0 => PanelColor::Black,
            1 => PanelColor::White,
            _ => unreachable!(),
        }
    }
}

enum TurnDirection {
    Counterclockwise,
    Clockwise,
}

impl From<i64> for TurnDirection {
    fn from(v: i64) -> Self {
        match v {
            0 => TurnDirection::Counterclockwise,
            1 => TurnDirection::Clockwise,
            _ => unreachable!(),
        }
    }
}

#[derive(Copy, Clone)]
enum Direction {
    Up,
    Right,
    Down,
    Left,
}

impl From<i64> for Direction {
    fn from(v: i64) -> Self {
        match v {
            0 => Direction::Up,
            1 => Direction::Right,
            2 => Direction::Down,
            3 => Direction::Left,
            _ => unreachable!(),
        }
    }
}

struct Robot {
    direction: Direction,
    loc: Point,
}

impl Robot {
    fn rotate(&mut self, turn: TurnDirection) {
        self.direction = Direction::from(
            (self.direction as i64
                + match turn {
                    TurnDirection::Counterclockwise => -1,
                    TurnDirection::Clockwise => 1,
                })
            .rem_euclid(4),
        );
    }

    fn move_forward(&mut self) {
        self.loc += match self.direction {
            Direction::Up => Point { x: -1, y: 0 },
            Direction::Right => Point { x: 0, y: 1 },
            Direction::Down => Point { x: 1, y: 0 },
            Direction::Left => Point { x: 0, y: -1 },
        }
    }
}

fn paint_hull(prog: &[i64], start_color: PanelColor) -> HashMap<Point, PanelColor> {
    let mut comp = intcode::Computer::new(prog, &[start_color as i64]);

    let mut robot = Robot {
        direction: Direction::Up,
        loc: Default::default(),
    };

    let mut panels: HashMap<Point, PanelColor> = HashMap::new();
    while let intcode::State::Output(paint_color) = comp.run() {
        panels.insert(robot.loc, PanelColor::from(paint_color));

        if let intcode::State::Output(turn_direction) = comp.run() {
            robot.rotate(TurnDirection::from(turn_direction));
        } else {
            break;
        }

        robot.move_forward();

        let panel_color_over = panels.get(&robot.loc).unwrap_or(&PanelColor::Black);
        comp.input.push_back(*panel_color_over as i64);
    }

    panels
}

fn render_registration_identifier(panels: &HashMap<Point, PanelColor>) -> String {
    let white_panel_locs: Vec<_> = panels
        .iter()
        .filter_map(|(&k, &v)| match v {
            PanelColor::White => Some(k),
            _ => None,
        })
        .collect();

    let delta_x = cmp::min(white_panel_locs.iter().min_by_key(|p| p.x).unwrap().x, 0).abs();
    let delta_y = cmp::min(white_panel_locs.iter().min_by_key(|p| p.y).unwrap().y, 0).abs();

    let white_panel_locs: Vec<_> = white_panel_locs
        .into_iter()
        .map(move |p| Point {
            x: p.x + delta_x,
            y: p.y + delta_y,
        })
        .collect();

    let max_x = white_panel_locs.iter().max_by_key(|p| p.x).unwrap().x;
    let max_y = white_panel_locs.iter().max_by_key(|p| p.y).unwrap().y;

    let mut hull =
        vec![vec![b' '; usize::try_from(max_y).unwrap() + 1]; usize::try_from(max_x).unwrap() + 1];

    for p in white_panel_locs {
        hull[usize::try_from(p.x).unwrap()][usize::try_from(p.y).unwrap()] = b'#';
    }

    let hull: Vec<_> = hull
        .into_iter()
        .map(|row| String::from_utf8(row).unwrap())
        .collect();
    hull.join("\n")
}

fn main() {
    let paint_program = intcode::parse_program(io::stdin());

    println!(
        "Part 1: {}",
        paint_hull(&paint_program, PanelColor::Black).len()
    );

    println!(
        "Part 2:\n{}",
        render_registration_identifier(&paint_hull(&paint_program, PanelColor::White))
    );
}
