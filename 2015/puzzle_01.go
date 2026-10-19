package main

import (
	"bytes"
	"fmt"
	"io"
	"os"
)

const basement = -1

func step(dir byte) int {
	switch dir {
	case '(':
		return 1
	case ')':
		return -1
	}
	panic(fmt.Sprintf("invalid direction %q", dir))
}

func finalFloor(instructions []byte) int {
	var floor int

	for _, dir := range instructions {
		floor += step(dir)
	}

	return floor
}

func firstPositionAtFloor(instructions []byte, dest int) int {
	var floor int

	for i, dir := range instructions {
		floor += step(dir)
		if floor == dest {
			return i + 1
		}
	}
	panic(fmt.Sprintf("never reached floor %d", dest))
}

func main() {
	input, err := io.ReadAll(os.Stdin)
	if err != nil {
		panic(err)
	}
	instructions := bytes.TrimSpace(input)

	fmt.Println("Part 1:", finalFloor(instructions))
	fmt.Println("Part 2:", firstPositionAtFloor(instructions, basement))
}
