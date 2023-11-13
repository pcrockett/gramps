#!/usr/bin/env bats

source tests/util.sh

@test "init - empty dir - initializes dir" {
    capture_output ./gramps init .
    test "${TEST_EXIT_CODE}" -eq 0
    test "${TEST_STDERR}" == ""
    test -f "${TEST_CWD}/README.md"

    local expected_stdout="^Here is your private key\. Write it down\. You will need it to decrypt
files, however it will never be displayed again after this:

  \w{5} \w{5} \w{5} \w{5}
  \w{5} \w{5} \w{5} \w{5}
  \w{5} \w{5} \w{5} \w{3}"
    if ! [[ "${TEST_STDOUT}" =~ ${expected_stdout} ]]; then
        printf "******STDOUT:******\n%s\n*******************\n" "${TEST_STDOUT}"
        fail "stdout didn't match expected."
    fi

    grep --perl-regexp --line-regexp '^age1\w+$' "${TEST_CWD}/.pubkey"
}

@test "init - already initialized - stops" {
    ./gramps init .
    capture_output ./gramps init .
    if [ "${TEST_EXIT_CODE}" -eq 0 ]; then
        fail "second \`init\` call didn't fail"
    else
        # the following `printf` won't show up unless the test fails
        printf "******STDERR:******\n%s\n*******************\n" "${TEST_STDERR}"
        echo "${TEST_STDERR}" | grep --fixed-strings --line-regexp "FATAL: Already initialized: ${TEST_CWD}"
    fi
}
