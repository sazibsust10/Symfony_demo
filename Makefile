# Makefile for Symfony Docker Image

# Variables
IMAGE_NAME = symfony-demo
IMAGE_TAG ?= latest
DOCKERFILE ?= deploy/Dockerfile
CONTEXT ?= .

# Targets

.PHONY: all build push

all: build

build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) -f $(DOCKERFILE) $(CONTEXT)

push:
	docker push $(IMAGE_NAME):$(IMAGE_TAG)
