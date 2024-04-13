all: build lint test
.PHONY: all

build:
	@bashly generate
.PHONY: build

lint: gramps
	@shellcheck ./gramps src/*.sh tests/*.sh tests/*.bats && echo "No lint!"
.PHONY: lint

test: gramps
	@bats tests
.PHONY: test

install: gramps
	@cp gramps ~/.local/bin
.PHONY: install

release:
	@gh workflow run release.yml
.PHONY: release

gramps: settings.yml src/bashly.yml src/*.sh src/lib/*.sh
	@bashly generate
