#!/usr/bin/env bats

source tests/util.sh

@test "check - dir not initialized - fails" {
    capture_output gramps check .
    assert_stderr '^FATAL: Not a gramps repo: \.$'
    assert_no_stdout
    assert_exit_code 1
}

@test "check - dir doesnt exist - fails" {
    capture_output gramps check ./this/does/not/exist
    assert_stderr '^FATAL: Not a gramps repo: ./this/does/not/exist$'
    assert_no_stdout
    assert_exit_code 1
}

@test "check - file path is given - fails" {
    touch foo
    capture_output gramps check ./foo
    assert_stderr '^FATAL: Not a gramps repo: \./foo$'
    assert_no_stdout
    assert_exit_code 1
}

@test "check - valid files - shows OK" {
    gramps init .
    echo "foo" | gramps encrypt --repo . --filename foo.txt
    echo "foobar" | gramps encrypt --repo . --filename foobar.txt
    capture_output gramps check .
    assert_stdout "foo.txt.age: OK
foobar.txt.age: OK"
    assert_no_stderr
    assert_exit_code 0
}

@test "check - corrupt files - shows fail" {
    gramps init .
    echo "foo" | gramps encrypt --repo . --filename foo.txt
    echo "foobar" | gramps encrypt --repo . --filename foobar.txt

    echo "oops, file was modified" >> foo.txt.age

    capture_output gramps check .
    assert_stdout "^foo.txt.age: FAILED
foobar.txt.age: OK\$"
    assert_stderr "^sha256sum: WARNING: 1 computed checksum did NOT match\$"
    assert_exit_code 1
}

@test "check - missing files - shows missing" {
    gramps init .
    echo "foo" | gramps encrypt --repo . --filename foo.txt
    echo "foobar" | gramps encrypt --repo . --filename foobar.txt
    rm foobar.txt.age

    capture_output gramps check .
    assert_stdout "^foo.txt.age: OK
foobar.txt.age: FAILED open or read\$"
    assert_stderr "^sha256sum: foobar.txt.age: No such file or directory
sha256sum: WARNING: 1 listed file could not be read\$"
    assert_exit_code 1
}
