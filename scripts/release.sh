#!/usr/bin/env bash
set -Eeuo pipefail

# gets version information from bashly config file and creates a github release
#
# dependencies:
#
# * fx <https://fx.wtf/>
# * github cli <https://cli.github.com/>
#

THIS_SCRIPT="$(readlink -f "${0}")"

panic() {
    echo "FATAL: ${*}" >&2
    exit 1
}

init() {
    local scripts_dir
    scripts_dir="$(dirname "${THIS_SCRIPT}")"
    REPO_DIR="$(dirname "${scripts_dir}")"
    cd "${REPO_DIR}"
}

run_ci() {
    make docker-ci
    test -f gramps || panic "CI didn't generate a new gramps executable"
}

create_release() {
    local tag="${1}"
    GH_PROMPT_DISABLED=1 \
        gh release create --title "${tag}" "${tag}" gramps
}

main() {
    init
    run_ci
    local tag url
    tag="v$(fx src/bashly.yml '.version')"
    url="$(create_release "${tag}")"
    echo "new release created: ${url}"
}

main "${@}"
