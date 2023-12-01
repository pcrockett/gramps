#!/usr/bin/env bats

source tests/util.sh

DUMMY_PRIVATE_KEY='01WCVP648UDC5N82CDPWA8ZZ6XDEL74YMR5FDJ95N8HHZSZ8YVF0MQ90GQ8E'
#    AGE-SECRET-KEY-1WCVP648UDC5N82CDPWA8ZZ6XDEL74YMR5FDJ95N8HHZSZ8YVF0MQ90GQ8E

ENCRYPTED_CONTENTS='-----BEGIN AGE ENCRYPTED FILE-----
YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSBQakRDdGcvZ2Ztd1poZmxu
MGZTL0RuUDl2c1dmd0V3c1dtSnEreVNnSEZNCllLUjdRQU9UZUN3dnA1Tko5VkRk
UnBBRDFGMHhYc3JGWndvNzUzcEtQaWsKLS0tIDlaVWlNTStpcWxKbk9kc3VOUHM1
bW1BczhvOEg1QnNxQUtsZXZQajF4K1UK0VFieU4eXQgIbNtQVGTdI83oJvqNDl1y
49fBJu+0jHWqJew=
-----END AGE ENCRYPTED FILE-----'

@test "decrypt - improperly formatted key - fails" {
    echo "${ENCRYPTED_CONTENTS}" > foo.txt.age
    capture_output gramps decrypt foo.txt.age \
        < <(echo "this is a bad key")
    assert_no_stdout
    assert_stderr '^FATAL: Invalid key format$'
    assert_exit_code 1
}

@test "decrypt - valid but wrong key - fails" {
    echo "${ENCRYPTED_CONTENTS}" > foo.txt.age
    capture_output gramps decrypt foo.txt.age \
        < <(echo '01QSPPLGWHQKDWR7HA37KNT0TS0QWLMFDA0LUD8N2W92LCDHF7ALVQ8CQJ04')
    assert_no_stdout
    assert_stderr '^FATAL: Unable to decrypt; perhaps a mistyped key\?$'
    assert_exit_code 1
}

@test "decrypt - wrong key version - fails" {
    echo "${ENCRYPTED_CONTENTS}" > foo.txt.age
    capture_output gramps decrypt foo.txt.age \
        < <(echo '02QSPPLGWHQKDWR7HA37KNT0TS0QWLMFDA0LUD8N2W92LCDHF7ALVQ8CQJ04')
    assert_no_stdout
    assert_stderr '^FATAL: Key generated by different version of gramps$'
    assert_exit_code 1
}

@test "decrypt - uninitialized input dir - succeeds" {
    # right now there's no reason for gramps to fail when decrypting something with the private key,
    # EVEN THOUGH the file we're decrypting isn't in a valid gramps repository.
    echo "${ENCRYPTED_CONTENTS}" > foo.txt.age
    capture_output gramps decrypt foo.txt.age \
        < <(echo "${DUMMY_PRIVATE_KEY}")
    assert_no_stderr
    assert_stdout "foo"
    assert_exit_code 0
}

@test "decrypt - lowercase private key - succeeds" {
    echo "${ENCRYPTED_CONTENTS}" > foo.txt.age
    capture_output gramps decrypt foo.txt.age \
        < <(echo '01wcvp648udc5n82cdpwa8zz6xdel74ymr5fdj95n8hhzsz8yvf0mq90gq8e')
    assert_no_stderr
    assert_stdout "foo"
    assert_exit_code 0
}

@test "decrypt - output file specified - succeeds" {
    echo "${ENCRYPTED_CONTENTS}" > foo.txt.age
    capture_output gramps decrypt foo.txt.age foo.txt \
        < <(echo "${DUMMY_PRIVATE_KEY}")
    assert_no_stderr
    assert_stdout '^File saved at foo\.txt$'
    assert_exit_code 0
}

@test "decrypt - input file doesnt exist - fails" {
    capture_output gramps decrypt "${HOME}/foo.txt.age"
    assert_no_stdout
    assert_stderr '^FATAL: File not found: /tmp/gramps-home\.\w+/foo\.txt\.age$'
    assert_exit_code 1
}

@test "decrypt - output file already exists - fails" {
    echo "${ENCRYPTED_CONTENTS}" > foo.txt.age
    touch ./foo.txt
    capture_output gramps decrypt ./foo.txt.age ./foo.txt < <(echo "${DUMMY_PRIVATE_KEY}")
    assert_no_stdout
    assert_stderr '^FATAL: Already exists: \./foo\.txt$'
    assert_exit_code 1
}

@test "decrypt - output file is a directory - fails" {
    mkdir ./foo
    echo "${ENCRYPTED_CONTENTS}" > ./foo.txt.age
    capture_output gramps decrypt ./foo.txt.age ./foo < <(echo "${DUMMY_PRIVATE_KEY}")
    assert_no_stdout
    assert_stderr '^FATAL: Already exists: \./foo$'
    assert_exit_code 1
}
