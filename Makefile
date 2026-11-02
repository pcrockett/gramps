all: build lint test
.PHONY: all

build: gramps
.PHONY: build

lint: gramps
	@pre-commit run --all-files
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
