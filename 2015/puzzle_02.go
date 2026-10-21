//go:build ignore

package main

import (
	"bufio"
	"fmt"
	"os"
)

type box struct {
	l, w, h int
}

func area(a, b int) int {
	return a * b
}

func surfaceArea(tb, lr, fb int) int {
	return 2*tb + 2*lr + 2*fb
}

func requiredWrappingPaper(b box) int {
	topBottom := area(b.l, b.w)
	leftRight := area(b.w, b.h)
	frontBack := area(b.l, b.h)

	extra := min(topBottom, leftRight, frontBack)

	return surfaceArea(topBottom, leftRight, frontBack) + extra
}

func totalSquareFeet(boxes []box) int {
	result := 0

	for _, b := range boxes {
		result += requiredWrappingPaper(b)
	}

	return result
}

func main() {
	var boxes []box

	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		var b box
		_, _ = fmt.Sscanf(scanner.Text(), "%dx%dx%d", &b.l, &b.w, &b.h)
		boxes = append(boxes, b)
	}
	_ = scanner.Err()

	fmt.Println("Part 1:", totalSquareFeet(boxes))
	// fmt.Println("Part 2:", firstPositionAtFloor(instructions, basement))

}
