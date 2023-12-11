#!/usr/bin/env bats

source tests/util.sh

@test "rm - file exists - removes file and checksum" {
    export GRAMPS_DEFAULT_REPO=the_repo
    gramps init
    echo "foo" | gramps encrypt --filename foo.txt
    test -f "the_repo/foo.txt.age"
    gramps rm --filename foo.txt
    test ! -f "the_repo/foo.txt.age" || fail "file was not removed from the repo"
    if grep --fixed-strings --word-regexp "foo.txt.age" "the_repo/.gramps/sha256sum"; then
        fail "file was not removed from checksum file"
    fi
}

@test "rm - file does not exist - fails" {
    fail "not implemented yet"
}

@test "rm - file in .gramps dir - fails" {
    fail "not implemented yet"
}

@test "rm - file outside of gramps repo - fails" {
    fail "not implemented yet"
}

@test "rm - filename flag - works same as file path" {
    fail "not implemented yet"
}
