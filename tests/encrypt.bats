#!/usr/bin/env bats

source tests/util.sh

@test "encrypt - uninitialized output dir - fails" {
    echo "foo" > "${HOME}/foo.txt"
    capture_output gramps encrypt "${HOME}/foo.txt" --output .
    assert_exit_code 1
    assert_no_stdout
    assert_stderr '^FATAL: Not a gramps directory: /tmp/gramps-test\.\w+$'
}

@test "encrypt - input file doesnt exist - fails" {
    gramps init . &> /dev/null
    capture_output gramps encrypt "${HOME}/foo.txt" --output .
    assert_exit_code 1
    assert_no_stdout
    assert_stderr '^FATAL: File not found: /tmp/gramps-home\.\w+/foo\.txt$'
}

@test "encrypt - stdin to initialized output dir - succeeds" {
    fail "not implemented yet"
}

@test "encrypt - input file to initialized output dir - succeeds" {
    fail "not implemented yet"
}
