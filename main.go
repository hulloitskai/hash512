package main

import (
	"fmt"
	"log"
	"os"

	"github.com/urfave/cli"
	"golang.org/x/crypto/bcrypt"
)

const version = "0.1.0"

func main() {
	app := cli.NewApp()
	app.Usage = "a tiny utility for making bcrypt password hashes"
	app.UsageText = fmt.Sprintf(
		"bcrypt [-c, --cost <number between %d and %d>]",
		bcrypt.MinCost, bcrypt.MaxCost,
	)
	app.Version = version
	app.Flags = flags
	app.Action = bpasswd

	if err := app.Run(os.Args); err != nil {
		log.Fatalf("Failed to run app: %v", err)
	}
}
