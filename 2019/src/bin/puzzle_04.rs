use std::io;

const BASE: u32 = 10;

/// Going left to right, check if digits never decrease.
fn digits_never_decrease(num: u32) -> bool {
    let mut prev_digit = num % BASE;
    let mut x = num / BASE;
    while x > 0 {
        let digit = x % BASE;
        if prev_digit < digit {
            return false;
        }
        prev_digit = digit;
        x /= BASE;
    }

    true
}

fn contains_adjacent_digits_same(num: u32) -> bool {
    debug_assert!(digits_never_decrease(num));

    let mut prev_digit = num % BASE;
    let mut x = num / BASE;
    while x > 0 {
        let digit = x % BASE;
        if digit == prev_digit {
            return true;
        }
        prev_digit = digit;
        x /= BASE;
    }

    false
}

fn contains_strict_adjacent_digit_pair(num: u32) -> bool {
    debug_assert!(digits_never_decrease(num));

    let mut counts = [0; BASE as usize];

    let mut x = num;
    while x > 0 {
        counts[(x % BASE) as usize] += 1;
        x /= BASE;
    }

    counts.into_iter().any(|x| x == 2)
}

fn main() {
    let input_range: Vec<u32> = io::read_to_string(io::stdin())
        .unwrap()
        .trim()
        .split('-')
        .map(|x| x.parse().unwrap())
        .collect();

    assert!(input_range.len() == 2, "Only two numbers expected!");
    let password_range = input_range[0]..=input_range[1];

    let never_decreasing = password_range.filter(|&x| digits_never_decrease(x));
    let at_least_2_digits_same = never_decreasing.filter(|&x| contains_adjacent_digits_same(x));

    println!("Part 1: {}", at_least_2_digits_same.clone().count());

    let strict_digit_pairs = at_least_2_digits_same
        .into_iter()
        .filter(|&x| contains_strict_adjacent_digit_pair(x));

    println!("Part 2: {}", strict_digit_pairs.count());
}
