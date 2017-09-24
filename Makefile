PROJECT  := github.com/jlorgal/go-template

BINARIES := $(shell cd cmd; ls -d *)
PACKAGES := $(shell go list ./... | grep -v /vendor/)
LDFLAGS  := -X main.Version=1.0.0

.PHONY: help build build-% clean

define help
Usage: make <command>
Commands:
  help:  Show this help information
  dep:   Ensure dependencies with dep tool
  build: Build the application
  clean: Clean the project
endef
export help

help:
	@echo "$$help"

dep:
	dep ensure

build-%:
	go build -o "bin/$*" -i -ldflags="$(LDFLAGS)" "$(PROJECT)/cmd/$*"

build: dep $(addprefix build-, $(BINARIES))
	go fmt $(PACKAGES)
	go vet $(PACKAGES)
	golint $(PACKAGES)
	go test $(PACKAGES)

run: build
	bin/service

clean:
	go clean
	rm -rf bin/
