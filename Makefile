.PHONY: default clean build fmt lint vet cyclo ineffassign shellcheck errcheck goconst gosec abcgo style run test cover license help

BINARY:=app

default: build

clean: ## Run go clean
	@go clean

build: ## Run go build
	@echo "Building"
	@go build

fmt: ## Run go fmt -w for all sources
	@echo "Running go formatting"
	./scripts/gofmt.sh

lint: ## Run golint
	@echo "Running go lint"
	./scripts/golint.sh

vet: ## Run go vet. Report likely mistakes in source code
	@echo "Running go vet"
	./scripts/govet.sh

cyclo: ## Run gocyclo
	@echo "Running gocyclo"
	./scripts/gocyclo.sh

ineffassign: ## Run ineffassign checker
	@echo "Running ineffassign checker"
	./scripts/ineffassign.sh

shellcheck: ## Run shellcheck
	shellcheck --exclude=SC1090,SC2086,SC2034,SC1091 ./scripts/*.sh

errcheck: ## Run errcheck
	@echo "Running errcheck"
	./scripts/goerrcheck.sh

goconst: ## Run goconst checker
	@echo "Running goconst checker"
	./scripts/goconst.sh

gosec: ## Run gosec checker
	@echo "Running gosec checker"
	./scripts/gosec.sh

abcgo: ## Run ABC metrics checker
	@echo "Run ABC metrics checker"
	./scripts/abcgo.sh

style: fmt vet lint cyclo shellcheck errcheck goconst gosec ineffassign abcgo ## Run all the formatting related commands (fmt, vet, lint, cyclo) + check shell scripts

run: clean build ## Build the project and executes the binary
	./app

test: clean build ## Run the unit tests
	./scripts/unit-tests.sh

cover: test
	@go tool cover -html=coverage.out

license: install_addlicense
	addlicense -c "Red Hat, Inc" -l "apache" -v ./

help: ## Show this help screen
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@echo 'Available targets are:'
	@echo ''
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ''
