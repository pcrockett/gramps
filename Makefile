all: build lint test
.PHONY: all

build: gramps
.PHONY: build

lint:
	shellcheck ./gramps src/*.sh tests/*.sh
.PHONY: lint

test: gramps
	bats tests
.PHONY: test

gramps: settings.yml src/bashly.yml src/*.sh
	bashly generate
