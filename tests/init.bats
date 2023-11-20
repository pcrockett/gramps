#!/usr/bin/env bats

source tests/util.sh

@test "init - empty dir - initializes dir" {
    capture_output gramps init .
    assert_exit_code 0
    assert_no_stderr
    assert_stdout "^Here is your private key\\. Write it down\\. You will need it to decrypt
files, however it will never be displayed again after this:
╭───────────────────────╮
│01\w{3} \w{5} \w{5} \w{5}│
│\w{5} \w{5} \w{5} \w{5}│
│\w{5} \w{5} \w{5} \w{5}│
╰───────────────────────╯\$"

    pubkey_file="${TEST_CWD}/.gramps/pubkey"

    diff README.md <(echo "# Gramps Pseudo-Offline Backup

This is a [gramps](https://github.com/pcrockett/gramps) repository. \`gramps\` is just a Bash script
wrapper for the [age](https://github.com/FiloSottile/age) encryption tool.

Any \`*.age\` files you see here are encrypted with this public key:

    $(cat "${pubkey_file}")

The private key has been written down <!-- TODO: where did you write down your private key? -->

When you have the private key, you can decrypt files with the command:

    gramps decrypt [the_encrypted_file] [the_decrypted_file]
")

    grep --perl-regexp --line-regexp '^age1\w+$' "${pubkey_file}"
}

@test "init - already initialized - stops" {
    gramps init .
    capture_output gramps init .
    assert_exit_code 1
    assert_no_stdout
    assert_stderr "^FATAL: Already initialized: ${TEST_CWD}\$"
}

@test "init - README exists - warns" {
    touch README.md
    capture_output gramps init .
    assert_stdout '^WARNING: README\.md already exists\.'
    assert_no_stderr
    assert_exit_code 0
}

@test "init - no repo given - fails" {
    capture_output gramps init
    assert_stderr '^FATAL: Must specify a repository path via REPOSITORY_PATH parameter or GRAMPS_DEFAULT_REPO env variable\.$'
    assert_no_stdout
    assert_exit_code 1
}

@test "init - repo path via env variable - succeeds" {
    GRAMPS_DEFAULT_REPO="$(pwd)" capture_output gramps init
    assert_no_stderr
    assert_stdout '^Here is your private key\.'
    assert_exit_code 0
    test -d .gramps
}
