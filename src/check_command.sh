# shellcheck shell=bash
# shellcheck disable=SC2154  # variables like ${args} are defined in main script

repository_path="${args[repository_path]:-}"
if [ "${repository_path}" == "" ]; then
    repository_path="${GRAMPS_DEFAULT_REPO:-}"
fi
test "${repository_path}" != "" || panic "Must specify a repository path via REPOSITORY_PATH parameter or GRAMPS_DEFAULT_REPO env variable."

gramps_dir="${repository_path}/.gramps"

test -d "${gramps_dir}" || panic "Not a gramps repo: ${repository_path}"

sha256sum --check "${gramps_dir}/sha256sum"
