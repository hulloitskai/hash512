package main

import (
	"bytes"
	"fmt"
	"log"

	"github.com/urfave/cli"
	"golang.org/x/crypto/bcrypt"
	"golang.org/x/crypto/ssh/terminal"
)

func bpasswd(ctx *cli.Context) {
	cost := ctx.Int("cost")
	checkCost(&cost)

	pass := getPassword()
	hash := hashPass(pass, cost)
	fmt.Println(hash)
}

// checkCost will set c to bcrypt.DefaultCost if it is too large or too small.
func checkCost(c *int) {
	if *c > bcrypt.MaxCost {
		fmt.Printf("Cost %d exceeds maximum cost %d; setting cost to default "+
			"(%d).\n", *c, bcrypt.MaxCost, bcrypt.DefaultCost)
	} else if *c < bcrypt.MinCost {
		fmt.Printf("Cost %d is less than minimum cost %d; setting cost to "+
			"default (%d).\n", *c, bcrypt.MinCost, bcrypt.DefaultCost)
	} else {
		return
	}

	*c = bcrypt.DefaultCost
}

func getPassword() []byte {
	var (
		in, verify []byte
		err        error
	)

	fmt.Print("Enter password: ")
	if in, err = terminal.ReadPassword(0); err != nil {
		log.Fatalf("Failed to read input: %v", err)
	}

	fmt.Print("\nVerify password: ")
	if verify, err = terminal.ReadPassword(0); err != nil {
		log.Fatalf("Failed to read input: %v", err)
	}
	fmt.Println()

	if !bytes.Equal(in, verify) {
		log.Fatalf("\nVerification did not match password; exiting.")
	}

	return in
}

func hashPass(pass []byte, cost int) string {
	hash, err := bcrypt.GenerateFromPassword(pass, cost)
	if err != nil {
		log.Fatalf("\nError while generating hash: %v", err)
	}
	return string(hash)
}
