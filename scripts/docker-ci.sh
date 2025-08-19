#!/usr/bin/env bash
set -euo pipefail

GRAMPS_CI_IMAGE_NAME="${GRAMPS_CI_IMAGE_NAME:-"gramps-ci"}"
GRAMPS_CI_CONTAINER_NAME="${GRAMPS_CI_CONTAINER_NAME:-"gramps-ci"}"

init() {
    rm -f gramps
    docker container rm --force "${GRAMPS_CI_CONTAINER_NAME}" &>/dev/null
}

main() {
    init
    docker build --tag "${GRAMPS_CI_IMAGE_NAME}" --build-arg "GITHUB_TOKEN=${GITHUB_TOKEN:-}" .
    docker run --name "${GRAMPS_CI_CONTAINER_NAME}" "${GRAMPS_CI_IMAGE_NAME}" make all
    docker cp "${GRAMPS_CI_CONTAINER_NAME}:/repo/gramps" .
    docker container rm "${GRAMPS_CI_CONTAINER_NAME}" &>/dev/null
    test -f gramps
}

main
