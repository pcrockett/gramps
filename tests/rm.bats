#!/usr/bin/env bats
# shellcheck disable=SC2030  # env variables get exported in subshells; no global effect
# shellcheck disable=SC2031  # env variables get exported in subshells; no global effect

source tests/util.sh

@test "rm - file exists - removes file and checksum" {
    export GRAMPS_DEFAULT_REPO=the_repo
    gramps init > /dev/null
    echo "foo" | gramps encrypt --filename foo.txt

    gramps rm "${GRAMPS_DEFAULT_REPO}/foo.txt.age"

    test ! -f "${GRAMPS_DEFAULT_REPO}/foo.txt.age" || fail "file was not removed from the repo"
    if grep --fixed-strings --word-regexp "foo.txt.age" "${GRAMPS_DEFAULT_REPO}/.gramps/sha256sum"; then
        fail "file was not removed from checksum file"
    fi

    capture_output gramps check
    assert_no_stderr
    assert_stdout '.gramps/pubkey: OK'
    assert_exit_code 0
}

@test "rm - file does not exist - fails" {
    export GRAMPS_DEFAULT_REPO=the_repo
    gramps init > /dev/null
    capture_output gramps rm "${GRAMPS_DEFAULT_REPO}/bar.txt.age"
    assert_no_stdout
    assert_stderr '^FATAL: Does not exist: the_repo/bar\.txt\.age$'
    assert_exit_code 1
}

@test "rm - file within .gramps directory - fails" {
    export GRAMPS_DEFAULT_REPO=the_repo
    gramps init > /dev/null
    capture_output gramps rm "${GRAMPS_DEFAULT_REPO}/.gramps/sha256sum"
    assert_no_stdout
    assert_stderr '^FATAL: Unable to remove files in \.gramps directory\.$'
    assert_exit_code 1
}

@test "rm - .gramps directory - fails" {
    export GRAMPS_DEFAULT_REPO=the_repo
    gramps init > /dev/null
    capture_output gramps rm "${GRAMPS_DEFAULT_REPO}/.gramps"
    assert_no_stdout
    # shellcheck disable=SC2016  # yes I do want backticks in the string, am not expecting substitution
    assert_stderr '^FATAL: Unable to remove \.gramps directory\.$'
    assert_exit_code 1
}

@test "rm - file outside of gramps repo - fails" {
    export GRAMPS_DEFAULT_REPO=the_repo
    gramps init > /dev/null

    mkdir not_a_gramps_repo
    touch not_a_gramps_repo/foo.txt.age

    capture_output gramps rm not_a_gramps_repo/foo.txt.age
    assert_no_stdout
    assert_stderr '^FATAL: Not a gramps repository: not_a_gramps_repo$'
    assert_exit_code 1
}
