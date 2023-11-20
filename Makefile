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

install: gramps
	cp gramps ~/.local/bin
.PHONY: install

gramps: settings.yml src/bashly.yml src/*.sh src/lib/*.sh
	bashly generate
