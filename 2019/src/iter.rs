pub struct Permutation<T> {
    elements: Vec<T>,
    idx: usize,
    counter: Vec<usize>,
}

impl<T> Iterator for Permutation<T>
where
    T: Clone,
{
    type Item = Vec<T>;

    fn next(&mut self) -> Option<Self::Item> {
        if self.idx == 0 {
            self.idx += 1;
            return Some(self.elements.clone());
        }

        while self.idx < self.elements.len() {
            if self.counter[self.idx] < self.idx {
                if self.idx % 2 == 0 {
                    self.elements.swap(0, self.idx);
                } else {
                    self.elements.swap(self.counter[self.idx], self.idx)
                }
                self.counter[self.idx] += 1;
                self.idx = 1;
                return Some(self.elements.clone());
            } else {
                self.counter[self.idx] = 0;
                self.idx += 1;
            }
        }
        None
    }
}

pub fn permutation<T>(elements: &[T]) -> Permutation<T>
where
    T: Clone,
{
    Permutation {
        elements: elements.to_vec(),
        idx: 0,
        counter: vec![0; elements.len()],
    }
}
