# shellcheck shell=bash
# shellcheck disable=SC2154  # variables like ${repository_path} are defined in main script

set_repo_path_arg from_option
test -d "${repository_path}/.gramps" || panic "Not a gramps repository: ${repository_path}"

# file name should be in the format ${repo_name}_YYYY-MM-DD-HHmm.zip
repo_name="$(basename "${repository_path}")"
file_name="${repo_name}_$(date +%F-%H%M).zip"

echo "Repository exported to ${file_name}"
