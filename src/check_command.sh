# shellcheck shell=bash
# shellcheck disable=SC2154  # variables like ${args} are defined in main script

set_repo_path_arg from_positional
gramps_dir="${repository_path}/.gramps"

test -d "${gramps_dir}" || panic "Not a gramps repo: ${repository_path}"

sha256sum --check "${gramps_dir}/sha256sum"
