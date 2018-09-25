package main

import (
	"github.com/urfave/cli"
)

var flags = []cli.Flag{
	cli.IntFlag{
		Name:  "cost, c",
		Usage: "sets the cost of the bcrypt hashing algorithm (larger is more secure)",
		Value: defaultCost,
	},
}
