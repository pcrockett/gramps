# shellcheck shell=bash

setup() {
    set -Eeuo pipefail
    TEST_CWD="$(mktemp --directory --tmpdir=/tmp gramps-test.XXXXXX)"
    TEST_HOME="$(mktemp --directory --tmpdir=/tmp gramps-home.XXXXXX)"
    cp gramps "${TEST_CWD}"
    cd "${TEST_CWD}"
    export HOME="${TEST_HOME}"
}

teardown() {
    rm -rf "${TEST_CWD}"
    rm -rf "${TEST_HOME}"
}

fail() {
    echo "${*}"
    exit 1
}
