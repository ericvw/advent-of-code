use std::collections::HashMap;
use std::io;
use std::iter;

struct OrbitalRelationship<'a> {
    orbiter: &'a str,
    orbitted: &'a str,
}

fn total_orbits_from<'a>(
    o: &'a str,
    orbits: &HashMap<&str, &'a str>,
    counts: &mut HashMap<&'a str, u32>,
) -> u32 {
    let mut o = o;
    let mut s: Vec<_> = Vec::new();

    let mut count = loop {
        if let Some(&count) = counts.get(o) {
            break count;
        }

        if let Some(x) = orbits.get(o) {
            s.push(o);
            o = x;
        } else {
            break 0;
        }
    };

    while let Some(o) = s.pop() {
        count += 1;
        counts.insert(o, count);
    }

    count
}

fn orbit_count_checksum(orbits: &HashMap<&str, &str>) -> u32 {
    let mut count_cache: HashMap<&str, u32> = HashMap::new();
    orbits
        .keys()
        .map(|&x| total_orbits_from(x, orbits, &mut count_cache))
        .sum()
}

fn min_orbital_transfer_between(a: &str, b: &str, orbits: &HashMap<&str, &str>) -> u32 {
    let traverse = |o: &&str| orbits.get(o).copied();
    let mut a_path: Vec<_> = iter::successors(Some(a), traverse).collect();
    let mut b_path: Vec<_> = iter::successors(Some(b), traverse).collect();

    while !a_path.is_empty() && !b_path.is_empty() && a_path.last() == b_path.last() {
        a_path.pop();
        b_path.pop();
    }

    u32::try_from(a_path.len() + b_path.len()).unwrap()
}

fn main() {
    let lines: Vec<_> = io::stdin().lines().map(|line| line.unwrap()).collect();
    let orbits: Vec<_> = lines
        .iter()
        .map(|x| {
            let objs = x.split_once(')').unwrap();
            OrbitalRelationship {
                orbiter: objs.1,
                orbitted: objs.0,
            }
        })
        .collect();

    let orbits: HashMap<_, _> =
        HashMap::from_iter(orbits.into_iter().map(|x| (x.orbiter, x.orbitted)));

    println!("Part 1: {}", orbit_count_checksum(&orbits));

    const YOU: &str = "YOU";
    const SANTA: &str = "SAN";

    println!(
        "Part 2: {}",
        min_orbital_transfer_between(orbits[YOU], orbits[SANTA], &orbits,)
    );
}
