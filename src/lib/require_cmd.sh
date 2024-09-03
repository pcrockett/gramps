# shellcheck shell=bash

require_cmd() {
    for cmd in "${@}"; do
        command -v "${cmd}" &> /dev/null || panic "${cmd} command not found."
    done
}
