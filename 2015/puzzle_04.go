//go:build ignore

package main

import (
	"bytes"
	"crypto/md5"
	"encoding/hex"
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"
)

func lowestNumber(key []byte, zeros int) int {
	prefix := strings.Repeat("0", zeros)

	for i := 1; ; i++ {
		hasher := md5.New()
		hasher.Write(key)
		hasher.Write([]byte(strconv.Itoa(i)))

		checksum := hasher.Sum(nil)

		if strings.HasPrefix(hex.EncodeToString(checksum), prefix) {
			return i
		}
	}
}

func main() {
	input, err := io.ReadAll(os.Stdin)
	if err != nil {
		panic(err)
	}

	input = bytes.TrimSpace(input)

	fmt.Println("Part 1:", lowestNumber(input, 5))
	fmt.Println("Part 2:", lowestNumber(input, 6))
}
