#!/usr/bin/env bats

# end-to-end tests (i.e. make sure encrypted things can be decrypted as well)

source tests/util.sh

@test "end-to-end - encrypted file in initialized repo - can decrypt" {
    capture_output gramps init .

    # note the capture groups (...) in the following regex; we will get those values via
    # `BASH_REMATCH[*]` below.
    assert_stdout '.*
╭───────────────────────╮
│(.+)│
│(.+)│
│(.+)│
╰───────────────────────╯$'
    assert_exit_code 0

    # whitespace is ok; gramps should cut them all out:
    private_key="
        ${BASH_REMATCH[1]}
        ${BASH_REMATCH[2]}
        ${BASH_REMATCH[3]}
    "

    echo "foo" | gramps encrypt --output foo.txt.age
    capture_output gramps decrypt foo.txt.age < <(echo "${private_key}")
    assert_stdout "foo"
    assert_exit_code 0
}
