//go:build ignore

package main

import (
	"bytes"
	"fmt"
	"io"
	"os"
)

type point struct {
	x int
	y int
}

func (p point) move(o point) point {
	return point{
		x: p.x + o.x,
		y: p.y + o.y,
	}
}

func parseMove(dir byte) point {
	switch dir {
	case '^':
		return point{x: 0, y: -1}
	case 'v':
		return point{x: 0, y: 1}
	case '>':
		return point{x: 1, y: 0}
	case '<':
		return point{x: -1, y: 0}
	}
	panic(fmt.Sprintf("invalid direction %q", dir))
}

type houses map[point]struct{}

func countHouses(moves []point, nCouriers int) int {
	couriers := make([]point, nCouriers)
	visited := houses{point{}: {}}

	for i, m := range moves {
		c := &couriers[i%nCouriers]
		*c = c.move(m)
		visited[*c] = struct{}{}
	}

	return len(visited)
}

func main() {
	input, err := io.ReadAll(os.Stdin)
	if err != nil {
		panic(err)
	}

	input = bytes.TrimSpace(input)

	moves := make([]point, 0, len(input))
	for _, d := range input {
		moves = append(moves, parseMove(d))
	}

	fmt.Println("Part 1:", countHouses(moves, 1))
	fmt.Println("Part 2:", countHouses(moves, 2))
}
