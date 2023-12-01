# shellcheck shell=bash

prompt_if_interactive() {
    # execute a command that reads from stdin.
    #
    # * if the user is on an interactive tty, prompt them with instructions
    #   and write a newline when finished. all additional output goes to stderr.
    # * if the user is NOT an on an interactive tty (i.e. piping / redirecting)
    #   then just execute the command without any additional noise.
    #
    # first arg is a prompt for the user to enter something. all other args for
    # this function should be the command you want to execute.

    local prompt="${1}"
    shift 1

    if tty &> /dev/null; then
        # an interactive user is at the keyboard. tell them what to do.
        is_tty="true"
        echo "${prompt} Press Ctrl + D when finished." >&2
    fi

    "${@}"

    if [ "${is_tty:-}" = "true" ]; then
        # if the user doesn't hit enter, all further output will be dumped
        # onto the end of what they just typed. add a newline for them,
        # just in case.
        echo >&2
    fi
}
