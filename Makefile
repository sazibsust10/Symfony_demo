# Makefile for Symfony Docker Image

# Variables
IMAGE_NAME = ghcr.io/sazibsust10/symfony-demo
IMAGE_TAG ?= 1.0.0
DOCKERFILE ?= deploy/Dockerfile
CONTEXT ?= .

# Targets

.PHONY: all build push

all: build

build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) -f $(DOCKERFILE) $(CONTEXT)

push:
	docker push $(IMAGE_NAME):$(IMAGE_TAG)
