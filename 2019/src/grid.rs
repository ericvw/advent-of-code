use std::ops::Add;

#[derive(Debug, Copy, Clone, Hash, Eq, PartialEq)]
pub struct Coordinate(pub i32, pub i32);

impl Coordinate {
    pub fn manhattan_distance(&self, Coordinate(x, y): Coordinate) -> u32 {
        x.abs_diff(self.0) + y.abs_diff(self.1)
    }
}

impl Add for Coordinate {
    type Output = Self;

    fn add(self, other: Self) -> Self {
        Self(self.0 + other.0, self.1 + other.1)
    }
}
