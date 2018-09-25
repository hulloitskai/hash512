# bpasswd

_A tiny CLI utility for making bcrypt password hashes._

**Check out the [releases](/releases) for downloads.**

## Usage

```bash
./bpasswd -c <cost> # cost is related to hash security, defaults to 15
## Input: The password to hash (x2, once for verification).
## Output: The resulting hash.
```
