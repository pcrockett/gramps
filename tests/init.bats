#!/usr/bin/env bats

source tests/util.sh

@test "init - empty dir - initializes dir" {
    ./gramps init .
    test -f "${TEST_CWD}/.pubkey"
    test -f "${TEST_CWD}/README.md"
}

@test "init - already initialized - stops" {
    ./gramps init .
    capture_output ./gramps init .
    if [ "${TEST_EXIT_CODE}" -eq 0 ]; then
        fail "second \`init\` call didn't fail"
    else
        # the following `printf` won't show up unless the test fails
        printf "******STDERR:******\n%s\n*******************" "${TEST_STDERR}"
        echo "${TEST_STDERR}" | grep --fixed-strings --line-regexp "FATAL: Already initialized: ${TEST_CWD}"
    fi
}
