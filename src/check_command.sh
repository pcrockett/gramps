# shellcheck shell=bash

# shellcheck disable=SC2154  # variables like ${args} are defined in main script
directory_path="${args[directory_path]}"
gramps_dir="${directory_path}/.gramps"

test -d "${gramps_dir}" || panic "Not a gramps repo: ${directory_path}"

sha256sum --check "${gramps_dir}/sha256sum"
