#!/usr/bin/env bats

source tests/util.sh

@test "init - empty dir - initializes dir" {
    capture_output ./gramps init .
    assert_exit_code 0
    assert_stderr ""
    assert_stdout "^Here is your private key\\. Write it down\\. You will need it to decrypt
files, however it will never be displayed again after this:
╭───────────────────────╮
│01\w{3} \w{5} \w{5} \w{5}│
│\w{5} \w{5} \w{5} \w{5}│
│\w{5} \w{5} \w{5} \w{5}│
╰───────────────────────╯\$"

    test -f "${TEST_CWD}/README.md"
    grep --perl-regexp --line-regexp '^age1\w+$' "${TEST_CWD}/.pubkey"
}

@test "init - already initialized - stops" {
    ./gramps init .
    capture_output ./gramps init .
    assert_exit_code 1
    assert_stdout ""
    assert_stderr "^FATAL: Already initialized: ${TEST_CWD}\$"
}
