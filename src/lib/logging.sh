# shellcheck shell=bash

panic() {
    # for when you really shouldn't keep calm and carry on
    echo "FATAL: ${*}" >&2
    exit 1
}
