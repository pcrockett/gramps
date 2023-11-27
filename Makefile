all: build lint test
.PHONY: all

build: gramps
.PHONY: build

lint: gramps
	shellcheck ./gramps src/*.sh tests/*.sh tests/*.bats
.PHONY: lint

test: gramps
	bats tests
.PHONY: test

install: gramps
	cp gramps ~/.local/bin
.PHONY: install

gramps: settings.yml src/bashly.yml src/*.sh src/lib/*.sh
	bashly generate
