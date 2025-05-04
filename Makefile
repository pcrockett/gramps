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

ci:
	@rm --force gramps
	@docker build --tag gramps-ci .
	@docker container rm --force gramps-ci &>/dev/null
	@docker run --name gramps-ci gramps-ci /bin/bash -c make build lint test
	@docker cp gramps-ci:/repo/gramps .
	@docker container rm --force gramps-ci &>/dev/null
	@test -f gramps

gramps: settings.yml src/bashly.yml src/*.sh src/lib/*.sh
	@bashly generate
