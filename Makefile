PROJECT  := github.com/jlorgal/go-template

BINARIES := $(shell cd cmd; ls -d *)
PACKAGES := $(shell go list ./... | grep -v /vendor/)
LDFLAGS  := -X main.Version=1.0.0

.PHONY: help build build-% clean

define help
Usage: make <command>
Commands:
  help:  Show this help information
  build: Build the application
  clean: Clean the project
endef
export help

help:
	@echo "$$help"

build-%:
	go build -o "bin/$*" -i -ldflags="$(LDFLAGS)" "$(PROJECT)/cmd/$*"

build: $(addprefix build-, $(BINARIES))
	go fmt $(PACKAGES)
	go vet $(PACKAGES)
	golint $(PACKAGES)
	go test $(PACKAGES)

clean:
	go clean
	rm -rf bin/