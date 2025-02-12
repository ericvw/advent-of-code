use std::convert::From;
use std::fmt;
use std::io;

const RADIX: u32 = 10;
const IMAGE_WIDTH: u32 = 25;
const IMAGE_HEIGHT: u32 = 6;

enum PixelColor {
    Black,
    White,
    Transparent,
}

impl From<u8> for PixelColor {
    fn from(v: u8) -> Self {
        match v {
            0 => PixelColor::Black,
            1 => PixelColor::White,
            2 => PixelColor::Transparent,
            _ => unreachable!(),
        }
    }
}

struct Layer<'a> {
    data: &'a [u8],
    digits: [u32; RADIX as usize],
}

impl<'a> Layer<'a> {
    pub fn new(data: &'a [u8]) -> Self {
        let mut digits = [0; RADIX as usize];
        for &i in data {
            digits[usize::from(i)] += 1;
        }

        Self { data, digits }
    }
}

struct Image<'a> {
    width: u32,
    height: u32,
    pub layers: Vec<Layer<'a>>,
}

impl<'a> Image<'a> {
    pub fn new(data: &'a [u8], width: u32, height: u32) -> Self {
        let num_pixels = usize::try_from(width * height).unwrap();
        assert!(data.len() % num_pixels == 0);

        Self {
            width,
            height,
            layers: (0..data.len() / num_pixels)
                .map(|i| Layer::new(&data[i * num_pixels..(i + 1) * num_pixels]))
                .collect(),
        }
    }

    pub fn render(&self, row: u32, col: u32) -> PixelColor {
        let row = usize::try_from(row).unwrap();
        let col = usize::try_from(col).unwrap();
        let width = usize::try_from(self.width).unwrap();

        for layer in &self.layers {
            let pixel = PixelColor::from(layer.data[row * width + col]);
            if let PixelColor::Transparent = pixel {
                continue;
            }
            return pixel;
        }
        unreachable!();
    }
}

impl fmt::Display for Image<'_> {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        for row in 0..self.height {
            for col in 0..self.width {
                write!(
                    f,
                    "{}",
                    match self.render(row, col) {
                        PixelColor::Black => " ",
                        PixelColor::White => "#",
                        _ => unreachable!(),
                    }
                )?
            }
            writeln!(f)?
        }
        Ok(())
    }
}

fn main() {
    let bios_password: Vec<u8> = io::read_to_string(io::stdin())
        .unwrap()
        .trim()
        .chars()
        .map(|x| u8::try_from(x.to_digit(RADIX).unwrap()).unwrap())
        .collect();

    let image = Image::new(&bios_password[..], IMAGE_WIDTH, IMAGE_HEIGHT);

    let layer_idx_with_fewest_0s = image
        .layers
        .iter()
        .enumerate()
        .min_by(|(_, a), (_, b)| a.digits[0].cmp(&b.digits[0]))
        .map(|(i, _)| i)
        .unwrap();

    let layer_with_fewest_0s = &image.layers[layer_idx_with_fewest_0s];

    println!(
        "Part 1: {}",
        layer_with_fewest_0s.digits[1] * layer_with_fewest_0s.digits[2]
    );

    print!("Part 2:\n{}", image);
}
