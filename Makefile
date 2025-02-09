all: build lint test
.PHONY: all

build: gramps
.PHONY: build

lint: gramps
	@shellcheck ./gramps src/*.sh tests/*.sh tests/*.bats && echo "No lint!"
.PHONY: lint

test: gramps
	@bats tests
.PHONY: test

docker-ci:
	@rm -f gramps
	@docker container rm gramps-ci || true
	@docker build --tag gramps-ci .
	@docker run --name gramps-ci gramps-ci make all
	@docker cp gramps-ci:/repo/gramps .
	@docker container rm gramps-ci
.PHONY: docker-ci

install: gramps
	@cp gramps ~/.local/bin
.PHONY: install

release:
	@gh workflow run release.yml
.PHONY: release

gramps: settings.yml src/bashly.yml src/*.sh src/lib/*.sh
	@bashly generate
