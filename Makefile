ENVIRONMENT          ?= pull
PRODUCT_VERSION      ?= 1.0.0
ORG_NAME             ?= jlorgal
PROJECT_NAME         ?= go-template
DOCKER_REGISTRY      ?= docker.io
DOCKER_REGISTRY_AUTH ?=

# Customised settings based on the selected environment
include delivery/env/$(ENVIRONMENT)

DOCKER_IMAGE         := $(DOCKER_REGISTRY)/$(ORG_NAME)/$(PROJECT_NAME):$(PRODUCT_VERSION)
PACKAGES             := $(shell go list ./... | grep -v /vendor/)
LDFLAGS              := -X main.Version=$(PRODUCT_VERSION)

.PHONY: help dep build test-comp test-e2e package publish run clean pipeline-pull pipeline-dev pipeline

define help
Usage: make <command>
Commands:
  help:          Show this help information
  dep:           Ensure dependencies with dep tool
  build:         Build the application
  test-comp:     Pass component tests
  test-e2e:      Pass end-to-end tests
  package:       Create the docker image
  publish:       Publish the docker image
  run:           Launch the service with docker-compose (for testing purposes)
  clean:         Clean the project
  pipeline-pull: Launch pipeline to handle a pull request
  pipeline-dev:  Launch pipeline to handle the merge of a pull request
  pipeline:      Launch the pipeline for the selected environment
endef
export help

help:
	@echo "$$help"

dep:
	dep ensure

build: dep
	GOBIN=$$PWD/bin/ go install -ldflags="$(LDFLAGS)" ./...
	go fmt $(PACKAGES)
	go vet $(PACKAGES)
	golint $(PACKAGES)
	go test $(PACKAGES)

test-%:
	test/$*/test-$*.sh

package:
	docker build -f delivery/docker/release/Dockerfile -t $(DOCKER_IMAGE) .

publish:
	# docker login -u $$DOCKER_USER -p $$DOCKER_PASSWORD -e $$DOCKER_EMAIL $(DOCKER_REGISTRY_AUTH)
	# docker push -t $(DOCKER_IMAGE)
	# docker logout

deploy:
	@echo "Simulating the deployment of this service"

run: build
	bin/service

clean:
	go clean
	rm -rf bin/

pipeline-pull: build test-comp
pipeline-dev: build test-comp package publish deploy test-e2e
pipeline: pipeline-$(ENVIRONMENT)