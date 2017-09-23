package main

import "log"
import "github.com/jlorgal/go-template/demo"

// Version of the application. It is automatically set in build time.
var Version = "undefined"

func main() {
	log.Printf("Version: %s", Version)

	a := 1
	b := 2
	c := demo.Sum(a, b)
	log.Printf("%d + %d = %d", a, b, c)
}
