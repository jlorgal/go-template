PROJECT_NAME         ?= go-template
DOCKER_REGISTRY_AUTH ?=
DOCKER_REGISTRY      ?=
DOCKER_ORG           ?= jlorgal
DOCKER_API_VERSION   ?= 1.23
DOCKER_LOGIN         ?= jlorgal
DOCKER_PASSWORD      ?=

PRODUCT_VERSION      ?= $(get_version)
PRODUCT_REVISION     ?= $(get_revision)
BUILD_VERSION        ?= $(PRODUCT_VERSION)-$(PRODUCT_REVISION)
LDFLAGS              ?= -X main.Version=$(BUILD_VERSION)
DOCKER_IMAGE         ?= $(if $(DOCKER_REGISTRY),$(DOCKER_REGISTRY)/$(DOCKER_ORG)/$(PROJECT_NAME),$(DOCKER_ORG)/$(PROJECT_NAME))
PACKAGES             := $(shell go list ./... | grep -v /vendor/)

# Get the environment and import the settings.
# If the make target is pipeline-xxx, the environment is obtained from the target.
ifeq ($(patsubst pipeline-%,%,$(MAKECMDGOALS)),$(MAKECMDGOALS))
	ENVIRONMENT ?= pull
else
	override ENVIRONMENT := $(patsubst pipeline-%,%,$(MAKECMDGOALS))
endif
include delivery/env/$(ENVIRONMENT)

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
  promote:       Promote a docker image using the environment DOCKER_PROMOTION_TAG
  run:           Launch the service with docker-compose (for testing purposes)
  clean:         Clean the project
  pipeline-pull: Launch pipeline to handle a pull request
  pipeline-dev:  Launch pipeline to handle the merge of a pull request and deployment on the development environment
  pipeline-pre:  Launch pipeline to deploy the service on the preproduction environment
  pipeline-pro:  Launch pipeline to deploy the service on the production environment
  pipeline:      Launch the pipeline for the selected environment
  develenv-up:   Launch the development environment with a docker-compose of the service
  develenv-down: Stop the development environment
endef
export help

.PHONY: help dep build test-comp test-e2e package publish run clean \
		pipeline-pull pipeline-dev pipeline-pre pipeline-pro pipeline \
		develenv-up develenv-down

help:
	@echo "$$help"

dep:
	dep ensure

build: dep
	GOBIN=$$PWD/build/bin/ go install -ldflags="$(LDFLAGS)" ./...
	go fmt $(PACKAGES)
	go vet $(PACKAGES)
	golint $(PACKAGES)
	go test $(PACKAGES)

test-%:
	test/$*/test-$*.sh

package:
	docker build -f delivery/docker/release/Dockerfile -t $(DOCKER_IMAGE):$(BUILD_VERSION) .
	docker tag $(DOCKER_IMAGE):$(BUILD_VERSION) $(DOCKER_IMAGE):$(PRODUCT_VERSION)

publish:
	docker login -u $$DOCKER_USER -p $$DOCKER_PASSWORD $(DOCKER_REGISTRY_AUTH)
	docker push $(DOCKER_IMAGE):$(BUILD_VERSION)
	docker push $(DOCKER_IMAGE):$(PRODUCT_VERSION)
	docker logout

promote:
	docker tag $(DOCKER_IMAGE):$(BUILD_VERSION) $(DOCKER_IMAGE):$(DOCKER_PROMOTION_TAG)
	docker login -u $$DOCKER_USER -p $$DOCKER_PASSWORD $(DOCKER_REGISTRY_AUTH)
	docker push $(DOCKER_IMAGE):$(DOCKER_PROMOTION_TAG)
	docker logout

deploy:
	@echo "Simulating the deployment of this service in environment $(ENVIRONMENT)"

run: build
	build/bin/service

clean:
	go clean
	rm -rf build/ vendor/

pipeline-pull: build test-comp
pipeline-dev:  build test-comp package publish deploy test-e2e promote
pipeline-pre:  deploy test-e2e promote
pipeline-pro:  deploy test-e2e promote
pipeline:      pipeline-$(ENVIRONMENT)

develenv-up:
	docker-compose -p demo-dev -f delivery/docker/dev/docker-compose.yml build
	docker-compose -p demo-dev -f delivery/docker/dev/docker-compose.yml up -d

develenv-down:
	docker-compose -p demo-dev -f delivery/docker/dev/docker-compose.yml down

# Functions
get_version  := $(shell git describe --tags --long | cut -d'-' -f1)
get_revision := $(shell git describe --tags --long | cut -d'-' -f2-)
