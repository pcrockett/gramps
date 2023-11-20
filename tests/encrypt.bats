#!/usr/bin/env bats

source tests/util.sh

@test "encrypt - no repo given - fails" {
    capture_output gramps encrypt --filename whatever
    assert_stderr '^FATAL: Must specify a repository path via --repo parameter or GRAMPS_DEFAULT_REPO env variable\.$'
    assert_no_stdout
    assert_exit_code 1
}

@test "encrypt - uninitialized output dir - fails" {
    echo "foo" > "${HOME}/foo.txt"
    capture_output gramps encrypt "${HOME}/foo.txt" --repo .
    assert_exit_code 1
    assert_no_stdout
    assert_stderr '^FATAL: Not a gramps repository: /tmp/gramps-test\.\w+$'
}

@test "encrypt - input file doesnt exist - fails" {
    gramps init . &> /dev/null
    capture_output gramps encrypt "${HOME}/foo.txt" --repo .
    assert_exit_code 1
    assert_no_stdout
    assert_stderr '^FATAL: File not found: /tmp/gramps-home\.\w+/foo\.txt$'
}

@test "encrypt - output file already exists - fails" {
    gramps init . &> /dev/null
    touch ./foo.txt.age
    capture_output gramps encrypt --repo . --filename foo.txt < <(echo "foo")
    assert_no_stdout
    assert_stderr '^FATAL: Already exists: /tmp/gramps-test\.\w+/foo\.txt\.age$'
    assert_exit_code 1
}

@test "encrypt - output file is a directory - fails" {
    gramps init . &> /dev/null
    mkdir ./foo.txt.age
    capture_output gramps encrypt --repo . --filename ./foo.txt < <(echo "foo")
    assert_no_stdout
    assert_stderr '^FATAL: Already exists: /tmp/gramps-test\.\w+/foo\.txt\.age$'
    assert_exit_code 1
}

@test "encrypt - stdin to initialized output dir - succeeds" {
    gramps init . &> /dev/null
    capture_output gramps encrypt --repo . --filename foo.txt < <(echo "foo")
    assert_no_stderr
    assert_stdout '^File saved at /tmp/gramps-test\.\w+/foo\.txt\.age$'
    assert_exit_code 0

    # we'll test file contents elsewhere
    test -f ./foo.txt.age || fail "output file was not created"
}

@test "encrypt - input file to initialized output dir - succeeds" {
    gramps init . &> /dev/null
    echo "foo" > "${HOME}/foo.txt"
    capture_output gramps encrypt "${HOME}/foo.txt" --repo .
    assert_stdout '^File saved at /tmp/gramps-test\.\w+/foo\.txt\.age$'
    assert_no_stderr
    assert_exit_code 0

    # we'll test file contents elsewhere
    test -f ./foo.txt.age || fail "output file was not created"
}

@test "encrypt - single successful encryption - checksum added" {
    gramps init . &> /dev/null
    echo "foo" | gramps encrypt --repo . --filename foo.txt
    capture_output sha256sum --check .gramps/sha256sum
    assert_stdout "foo.txt.age: OK"
    assert_no_stderr
    assert_exit_code 0
}

@test "encrypt - many successful encryptions - checksum added" {
    gramps init . &> /dev/null
    echo "foo" | gramps encrypt --repo . --filename foo.txt
    echo "foo2" | gramps encrypt --repo . --filename foo2.txt
    capture_output sha256sum --check .gramps/sha256sum
    assert_stdout "foo.txt.age: OK
foo2.txt.age: OK"
    assert_no_stderr
    assert_exit_code 0
}

@test "encrypt - stdin with no filename - fails" {
    gramps init . &> /dev/null
    capture_output gramps encrypt --repo . < <(echo "foo")
    assert_stderr '^FATAL: Must specify --filename flag when no INPUT_PATH is specified\.$'
    assert_no_stdout
    assert_exit_code 1
}

@test "encrypt - both input_path and filename parameters specified - writes to filename" {
    gramps init . &> /dev/null
    echo "foo" > "${HOME}/foo.txt"
    capture_output gramps encrypt "${HOME}/foo.txt" --repo . --filename "bar.txt"
    assert_exit_code 0
    assert_stdout '^File saved at /tmp/gramps-test\.\w+/bar\.txt\.age$'

    # we'll test file contents elsewhere
    test ! -f ./foo.txt.age || fail "file was created with the wrong name"
    test -f ./bar.txt.age || fail "no output file was created"
}

@test "encrypt - default repo specified via env variable - saves to correct location" {
    default_repo="$(pwd)"
    GRAMPS_DEFAULT_REPO="${default_repo}" gramps init &> /dev/null

    echo "foo" > "${HOME}/foo.txt"
    GRAMPS_DEFAULT_REPO="${default_repo}" capture_output gramps encrypt "${HOME}/foo.txt"
    assert_exit_code 0

    test -f ./foo.txt.age || fail "no output file was created"
}
