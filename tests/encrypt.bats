#!/usr/bin/env bats

source tests/util.sh

@test "encrypt - uninitialized output dir - fails" {
    echo "foo" > "${HOME}/foo.txt"
    capture_output gramps encrypt "${HOME}/foo.txt" --output ./foo.txt.age
    assert_exit_code 1
    assert_no_stdout
    assert_stderr '^FATAL: Not a gramps repository: /tmp/gramps-test\.\w+/\.gramps$'
}

@test "encrypt - input file doesnt exist - fails" {
    gramps init . &> /dev/null
    capture_output gramps encrypt "${HOME}/foo.txt" --output ./foo.txt.age
    assert_exit_code 1
    assert_no_stdout
    assert_stderr '^FATAL: File not found: /tmp/gramps-home\.\w+/foo\.txt$'
}

@test "encrypt - output file already exists - fails" {
    gramps init . &> /dev/null
    touch ./foo.txt.age
    capture_output gramps encrypt --output ./foo.txt.age < <(echo "foo")
    assert_no_stdout
    assert_stderr '^FATAL: Already exists: /tmp/gramps-test\.\w+/foo\.txt\.age$'
    assert_exit_code 1
}

@test "encrypt - output file is a directory - fails" {
    gramps init . &> /dev/null
    mkdir ./foo.txt.age
    capture_output gramps encrypt --output ./foo.txt.age < <(echo "foo")
    assert_no_stdout
    assert_stderr '^FATAL: Already exists: /tmp/gramps-test\.\w+/foo\.txt\.age$'
    assert_exit_code 1
}

@test "encrypt - stdin to initialized output dir - succeeds" {
    gramps init . &> /dev/null
    capture_output gramps encrypt --output ./foo.txt.age < <(echo "foo")
    assert_stdout '^File saved at /tmp/gramps-test\.\w+/foo\.txt\.age$'
    assert_no_stderr
    assert_exit_code 0

    # we'll test file contents elsewhere
    test -f ./foo.txt.age || fail "output file was not created"
}

@test "encrypt - input file to initialized output dir - succeeds" {
    gramps init . &> /dev/null
    echo "foo" > "${HOME}/foo.txt"
    capture_output gramps encrypt "${HOME}/foo.txt" --output ./foo.txt.age
    assert_stdout '^File saved at /tmp/gramps-test\.\w+/foo\.txt\.age$'
    assert_no_stderr
    assert_exit_code 0

    # we'll test file contents elsewhere
    test -f ./foo.txt.age || fail "output file was not created"
}
