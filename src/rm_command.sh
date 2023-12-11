# shellcheck shell=bash

# shellcheck disable=SC2154  # `args` is defined in main script
file_path="${args[file_path]}"
file_name="$(basename "${file_path}")"
repo_dir="$(dirname "${file_path}")"

test -e "${file_path}" || panic "Does not exist: ${file_path}"
test "$(basename "${repo_dir}")" != ".gramps" || panic "Unable to remove files in .gramps directory."
test "${file_name}" != ".gramps" || panic "Unable to remove .gramps directory."
test -f "${repo_dir}/.gramps/sha256sum" || panic "Not a gramps repository: ${repo_dir}"

rm "${file_path}"

get_filtered_checksums() {
    grep --fixed-strings --word-regexp --invert-match "${file_name}" "${repo_dir}/.gramps/sha256sum"
}

get_filtered_checksums > "${repo_dir}/.gramps/sha256sum.tmp"
mv "${repo_dir}/.gramps/sha256sum.tmp" "${repo_dir}/.gramps/sha256sum"
