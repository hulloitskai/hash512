package main

import (
	"bytes"
	"fmt"
	"log"

	cc "github.com/GehirnInc/crypt/common"

	sha512 "github.com/GehirnInc/crypt/sha512_crypt"
	"github.com/urfave/cli"
	"golang.org/x/crypto/ssh/terminal"
)

func mkpasswd(ctx *cli.Context) {
	rounds := ctx.Int("rounds")
	pass := getPassword()
	hash := hashPass(pass, rounds)
	fmt.Println(hash)
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

func hashPass(pass []byte, rounds int) string {
	var (
		c    = sha512.New()
		salt = cc.Salt{
			MagicPrefix:   []byte(sha512.MagicPrefix),
			SaltLenMin:    sha512.SaltLenMin,
			SaltLenMax:    sha512.SaltLenMax,
			RoundsMin:     sha512.RoundsMin,
			RoundsMax:     sha512.RoundsMax,
			RoundsDefault: sha512.RoundsDefault,
		}
	)

	hash, err := c.Generate(pass, salt.GenerateWRounds(salt.SaltLenMax, rounds))
	if err != nil {
		log.Fatalf("Error while generating hash: %v", err)
	}

	return hash
}
