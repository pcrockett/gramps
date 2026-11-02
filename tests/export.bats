#!/usr/bin/env bats

source tests/util.sh

@test "export - uninitialized dir - fails" {
    mkdir dummy
    capture_output gramps export . --repo dummy
    assert_stderr '^FATAL: Not a gramps repository: dummy$'
    assert_no_stdout
    assert_exit_code 1
}

@test "export - repo dir doesnt exist - fails" {
    capture_output gramps export . --repo dummy
    assert_stderr '^FATAL: Not a gramps repository: dummy$'
    assert_no_stdout
    assert_exit_code 1
}

@test "export - empty initialized dir - succeeds" {
    gramps init my-gramps-repo
    capture_output gramps export . --repo my-gramps-repo
    assert_no_stderr
    assert_stdout '^Repository exported to (\./my-gramps-repo_[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{4}\.zip)$'
    filename="${BASH_REMATCH[1]}"
    test -f "${filename}" || fail "${filename} doesn't exist!"
    test -f "${filename}.sha256sum" || fail "${filename}.sha256sum doesn't exist!"
    sha256sum --check "${filename}.sha256sum" || fail "checksum failed!"
}

@test "export - contains files - files present in export" {
    export GRAMPS_DEFAULT_REPO=my-gramps-repo
    gramps init
    touch "${GRAMPS_DEFAULT_REPO}/some-random-file.txt"
    echo "hi" | gramps encrypt --filename foobar.txt

    gramps export . --filename test-export.zip

    test -f test-export.zip || fail "test-export.zip doesn't exist!"

    expected_files="$(
        echo ".gramps/
.gramps/sha256sum
.gramps/pubkey
foobar.txt.age
some-random-file.txt
README.md" | sort
    )"

    actual_files="$(
        zip --show-files test-export.zip \
            | grep --perl-regexp --only-matching '(?<=\s{2})\S+' \
            | sort
    )"

    test "${actual_files}" = "${expected_files}" || fail "
****** expected ******
${expected_files}
******* actual *******
${actual_files}
"
}
