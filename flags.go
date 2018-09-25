package main

import (
	"github.com/urfave/cli"
)

var flags = []cli.Flag{
	cli.IntFlag{
		Name:  "rounds, r",
		Usage: "sets the number of rounds for SHA-512 hashing (greater is more secure)",
		Value: defaultRounds,
	},
}
