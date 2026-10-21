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

func wrappingPaper(b box) int {
	topBottom := area(b.l, b.w)
	leftRight := area(b.w, b.h)
	frontBack := area(b.l, b.h)

	extra := min(topBottom, leftRight, frontBack)

	return surfaceArea(topBottom, leftRight, frontBack) + extra
}

func totalWrappingPaper(boxes []box) int {
	result := 0

	for _, b := range boxes {
		result += wrappingPaper(b)
	}

	return result
}

func perimeter(a, b int) int {
	return 2*a + 2*b
}

func volume(b box) int {
	return b.l * b.w * b.h
}

func ribbonToWrap(b box) int {
	return min(
		perimeter(b.l, b.w),
		perimeter(b.w, b.h),
		perimeter(b.l, b.h),
	)
}

func ribbon(b box) int {
	return ribbonToWrap(b) + volume(b)
}

func totalRibbon(boxes []box) int {
	result := 0

	for _, b := range boxes {
		result += ribbon(b)
	}

	return result
}

func main() {
	var boxes []box

	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		var b box
		if _, err := fmt.Sscanf(scanner.Text(), "%dx%dx%d", &b.l, &b.w, &b.h); err != nil {
			panic(err)
		}
		boxes = append(boxes, b)
	}
	if err := scanner.Err(); err != nil {
		panic(err)
	}

	fmt.Println("Part 1:", totalWrappingPaper(boxes))
	fmt.Println("Part 2:", totalRibbon(boxes))
}
