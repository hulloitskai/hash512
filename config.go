package main

import (
	"log"

	"github.com/urfave/cli"
)

func init() {
	// Disable log prefixes.
	log.SetFlags(0)
}

var defaultRounds = 8192

var flags = []cli.Flag{
	cli.IntFlag{
		Name:  "rounds, r",
		Usage: "sets the number of rounds for SHA-512 hashing (greater is more secure)",
		Value: defaultRounds,
	},
}
