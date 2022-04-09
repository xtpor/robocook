
git_commit_hash := $(shell git rev-parse --short HEAD)
git_changes := $(shell git status --porcelain)

all: publish-image

.PHONY: publish-image
publish-image:
ifeq ($(git_changes),)
	TAG=$(git_commit_hash) docker buildx bake
else
	$(error Cannot build docker image because git repository contains unstaged or untracked changes)
endif