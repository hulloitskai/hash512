## ----- Variables -----
PKG_NAME = $(shell basename "$$(pwd)")

## Source configs:
SRC_FILES = $(shell find . -type f -name '*.go' -not -path "./vendor/*")
SRC_PKGS = $(shell go list ./... | grep -v /vendor/)

## Testing configs:
TEST_TIMEOUT = 20s
COVER_OUT = coverage.out


## ------ Commands (targets) -----
## Setup / configuration commands:
.PHONY: default setup init verify dl vendor tidy get update fix

## Default target when no arguments are given to make (build and run program).
default: build run

## Setup sets up a Go module by initializing the module and then verifying
## its dependencies.
setup: init verify

## Initializes a Go module in the current directory.
## Variables: MODPATH
init:
	@printf "Initializing Go module:\n"
	@go mod init $(MODPATH)

## Verifies that Go module dependencies are satisfied.
verify:
	@printf "Verifying Go module dependencies:\n"
	@go mod verify

## Downloads Go module dependencies.
dl:
	@printf "Downloading Go modules... "
	@DL_OUT="$$(go mod download)"; \
		if [ -n "$$DL_OUT" ]; then printf "\n$$DL_OUT\n"; \
		else printf "done.\n"; \
		fi

## Vendors Go module dependencies.
vendor:
	@printf "Vendoring Go modules... "
	@VENDOR_OUT="$$(go mod vendor)"; \
		if [ -n "$$VENDOR_OUT" ];then printf "\n$$VENDOR_OUT\n"; \
		else printf "done.\n"; \
		fi

## Tidies Go module dependencies.
tidy:
	@printf "Tidying Go modules... "
	@TIDY_OUT="$$(go mod tidy 2>&1)"; \
		if [ -n "$$TIDY_OUT" ];then printf "\n$$TIDY_OUT\n"; \
		else printf "done.\n"; \
		fi

## Installs dependencies.
get:
	@printf "Installing dependencies... "
	@GOGET_OUT="$$(go get ./... 2>&1)"; \
		if [ -n "$$GOGET_OUT" ]; then printf "\n$$GOGET_OUT\n"; \
		else printf "done.\n"; \
		fi

## Installs and updates package dependencies.
update:
	@printf 'Installing and updating package dependencies with "go get"... '
	@GOGET_OUT="$$(go get -u 2>&1)"; \
		if [ -n "$$GOGET_OUT" ]; then \
		  printf "\n$$GOGET_OUT\n"; \
		else printf "done.\n"; \
		fi

## Fixes Go code using "go fix".
fix:
	@printf 'Fixing Go code with "go fix"... '
	@GOFIX_OUT="$$(go fix 2>&1)"; \
		if [ -n "$$GOFIX_OUT" ]; then printf "\n$$GOFIX_OUT\n"; \
		else printf "done.\n"; \
		fi


## Executing / installation commands:
.PHONY: run build build-all clean install get update fix tidy

## Builds and runs the program (package must be main).
run:
	@if [ -f ".env.sh" ]; then \
	   printf 'Exporting environment variables by sourcing ".env.sh"... '; \
	   . .env.sh; \
	   printf "done.\n"; \
	 fi
	@if [ -f "$(PKG_NAME)" ]; then \
	   printf 'Running "$(PKG_NAME)"...\n'; \
	   ./$(PKG_NAME); \
	 else printf '[ERROR] Could not find program "$(PKG_NAME)".\n'; \
	 fi

## Builds the program specified by the main package.
build:
	@printf "Building... "
	@GOBUILD_OUT="$$(go build 2>&1)"; \
		if [ -n "$$GOBUILD_OUT" ]; then \
		  printf "\n[ERROR] Failed to build program:\n"; \
		  printf "$$GOBUILD_OUT\n"; \
		  exit 1; \
		else printf "done.\n"; \
		fi

## Builds the program for all platforms.
build-all:
	@for GOOS in darwin linux windows; do \
		for GOARCH in amd64 386; do \
		  printf "Building for GOOS=$$GOOS, GOARCH=$$GOARCH... "; \
			OUTNAME="$(PKG_NAME)-$$GOOS-$$GOARCH"; \
			if [ $$GOOS == windows ]; then OUTNAME="$$OUTNAME.exe"; fi; \
		  GOBUILD_OUT="$$(GOOS=$$GOOS GOARCH=$$GOARCH go build -o "$$OUTNAME" 2>&1)"; \
		  if [ -n "$$GOBUILD_OUT" ]; then \
		    printf "\nError during build:\n"; \
		    printf "$$GOBUILD_OUT\n"; \
		    exit 1; \
		  else printf "done.\n"; \
		  fi; \
		done; \
	done

## Cleans built executables.
clean:
	@rm $$(ls -1 | egrep -v "^.*\.go$$" | egrep "$(PKG_NAME)") 2> /dev/null; \
	 if [ $$? -ne 0 ]; then \
	   printf "No removable executable files were found.\n".; \
	 fi

## Installs the program using "go install".
install:
	@printf 'Installing... '
	@GOINSTALL_OUT="$$(go install 2>&1)"; \
		if [ -n "$$GOBUILD_OUT" ]; then \
		  printf "\n[ERROR] failed to install:\n"; \
		  printf "$$GOINSTALL_OUT\n"; \
		  exit 1; \
		else printf "done.\n"; \
		fi


## Reviewing commands:
.PHONY: _review_base review review-race review-bench check fmt

## Formatting / code reviewing commands:
_review_base: verify fmt check

## Formats, checks, and tests the code.
review: _review_base test
review-v: _review_base test-v

## Like "review", but tests for race conditions.
review-race: _review_base test-race
review-race-v: _review_base test-race-v

## Like "review-race", but includes benchmarks.
review-bench: review-race bench
review-bench-v: review-race bench-v


## Checks for formatting, linting, and suspicious code.
check:
## Check formatting.
	@printf "Check fmt...                 "
	@GOFMT_OUT="$$(gofmt -l $(SRC_FILES) 2>&1)"; \
		if [ -n "$$GOFMT_OUT" ]; then \
		  printf '\n[WARN] Fix formatting issues in the following files with \
"make fmt":\n'; \
		  printf "$$GOFMT_OUT\n"; \
		  exit 1; \
		else printf "ok\n"; \
		fi

## Lint files.
	@printf "Check lint...                "
	@GOLINT_OUT="$(for PKG in "$(SRC_PKGS)"; do golint $$PKG 2>&1; done)"; \
		if [ -n "$$GOLINT_OUT" ]; then \
		  printf "\n"; \
		  for PKG in "$$GOLINT_OUT"; do \
		    printf "$$PKG\n"; \
		  done; \
		  printf "\n"; \
		  exit 1; \
		else printf "ok\n"; \
		fi

## Check suspicious code.
	@printf "Check vet...                 "
	@GOVET_OUT="$$(go vet 2>&1)"; \
		if [ -n "$$GOVET_OUT" ]; then \
		  printf '\n[WARN] Fix suspicious code from "go vet":\n'; \
		  printf "$$GOVET_OUT\n"; \
		  exit 1; \
		else printf "ok\n"; \
		fi

## Reformats code according to "gofmt".
fmt:
	@printf "Formatting source files...   "
	@GOFMT_OUT="$$(gofmt -l -s -w $(SRC_FILES) 2>&1)"; \
	 if [ -n "$$GOFMT_OUT" ]; then \
	 	printf "\n$$GOFT_OUT\n"; \
	 	exit 1; \
	 else printf "ok\n"; \
     fi;


## Testing commands:
.PHONY: test test-v test-race test-race-v bench bench-v

GOTEST = go test ./... -coverprofile=$(COVER_OUT) \
		               -covermode=atomic \
		               -timeout=$(TEST_TIMEOUT)
test:
	@printf "Testing:\n"
	@$(GOTEST)
test-v:
	@printf "Testing (verbose):\n"
	@$(GOTEST) -v

GOTEST_RACE = $(GOTEST) -race
test-race:
	@printf "Testing (race):\n"
	@$(GOTEST_RACE)
test-race-v:
	@printf "Testing (race, verbose):\n"
	@$(GOTEST_RACE) -v

GOBENCH = $(GOTEST) ./... -run=^$ -bench=. -benchmem
bench:
	@printf "Benchmarking:\n"
	@$(GOBENCH)
bench-v:
	@printf "Benchmarking (verbose):\n"
	@$(GOBENCH) -v


## Docker commands:
.PHONY: dk-ps dk-build dk-up dk-down dk-logs dk-build-up dk-start dk-stop \
	dk-clean dk-restart dk-up-logs dk-build-up dk-build-up-logs

DK = docker
DKCMP = docker-compose
dk-ps:
	@$(DKCMP) ps
dk-build:
	@$(DKCMP) build
dk-up:
	@$(DKCMP) up -d
dk-down:
	@$(DKCMP) down
dk-logs:
	@$(DKCMP) logs -f
dk-clean:
	@$(DK) container prune; $(DK) image prune; $(DK) network prune

dk-start:
	@$(DKCMP) start
dk-stop:
	@$(DKCMP) stop
dk-restart:
	@$(DKCMP) restart

dk-up-logs: dk-up dk-logs
dk-build-up: dk-build dk-up
dk-build-up-logs: dk-build dk-up dk-logs
