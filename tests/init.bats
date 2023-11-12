#!/usr/bin/env bats

source tests/util.sh

@test "init - empty dir - initializes dir" {
    ./gramps init .
    test -f "${TEST_CWD}/.pubkey"
    test -f "${TEST_CWD}/README.md"
}

@test "init - already initialized - stops" {
    ./gramps init .
    if ./gramps init .; then
        fail "second \`init\` call didn't fail"
    fi
}
