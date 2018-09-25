# hash512

_A tiny CLI utility for making SHA-512 password hashes._

**Check out the [releases](/releases) for downloade.**

## Motivation

I was generating password hashes for use with
[CoreOS Ignition](https://coreos.com/ignition/docs/latest/), when I realized
that the `mkpasswd` utility they suggested for making user account password
hashes only available on a few Linux distributions. I wanted a better,
cross-platform solution for making user password hashes that I could run on my
macOS development machine, without the need for a Linux VM.

So I made one.

## Usage

See `./hash512 --help` for full usage documentation.

```bash
./hash512 -r <rounds> # rounds is related to hash security, defaults to 8192
## Input: The password to hash (x2, once for verification).
## Output: The resulting hash.
```

<p align="center"><img src="./assets/preview.png" /></p>
