#!/usr/bin/env bats

source tests/util.sh

@test "export - uninitialized dir - fails" {
    mkdir dummy
    capture_output gramps export . --repo dummy
    assert_stderr '^FATAL: Not a gramps repository: dummy$'
    assert_no_stdout
    assert_exit_code 1
}

@test "export - initialized dir - succeeds" {
    gramps init my-gramps-repo
    capture_output gramps export . --repo my-gramps-repo
    assert_no_stderr
    assert_stdout '^Repository exported to (\./my-gramps-repo_[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{4}\.zip)$'
    filename="${BASH_REMATCH[1]}"
    test -f "${filename}" || fail "${filename} doesn't exist!"
}

# TODO: test contents of zip file. include `gramps` script and `age` in a bin dir.
# TODO: implement / test filename option
# TODO: implement / test GRAMPS_DEFAULT_REPO env variable
