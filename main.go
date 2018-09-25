package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/urfave/cli"
)

const version = "0.2.0"

func main() {
	app := cli.NewApp()
	app.Usage = "a tiny utility for making SHA-512 password hashes"
	app.UsageText = fmt.Sprintf(
		"%s [-r, --rounds <number of hashing rounds>]",
		filepath.Base(os.Args[0]),
	)
	app.Version = version
	app.Flags = flags
	app.Action = mkpasswd

	if err := app.Run(os.Args); err != nil {
		log.Fatalf("Failed to run app: %v", err)
	}
}
