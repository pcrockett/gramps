# shellcheck shell=bash
# shellcheck disable=SC2154  # variables like ${repository_path} are defined in main script

require_cmd sha256sum
set_repo_path_arg from_positional
gramps_dir="${repository_path}/.gramps"

test -d "${gramps_dir}" || panic "Not a gramps repo: ${repository_path}"

(
    cd "${repository_path}" || panic "unable to cd to ${repository_path}"
    sha256sum --check .gramps/sha256sum
)
