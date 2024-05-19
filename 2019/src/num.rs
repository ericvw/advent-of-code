pub fn gcd(mut a: i64, mut b: i64) -> u64 {
    while b != 0 {
        let t = b;
        b = a % b;
        a = t;
    }

    a.abs().try_into().unwrap()
}
