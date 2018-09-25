package main

import (
	"log"
)

func init() {
	// Disable log prefixes.
	log.SetFlags(0)
}

var defaultRounds = 8192
