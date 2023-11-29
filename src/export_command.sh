# shellcheck shell=bash
# shellcheck disable=SC2154  # variables like ${repository_path} are defined in main script

set_repo_path_arg from_option
test -d "${repository_path}/.gramps" || panic "Not a gramps repository: ${repository_path}"

output_directory="${args[output_directory]}"
test -d "${output_directory}" || panic "Does not exist: ${output_directory}"

file_name="${args[--filename]:-}"

if [ "${file_name}" = "" ]; then
    # file name should be in the format ${repo_name}_YYYY-MM-DD-HHmm.zip
    repo_name="$(basename "${repository_path}")"
    file_name="${repo_name}_$(date +%F-%H%M).zip"
fi

workspace="$(mktemp --directory)"
on_exit() {
    rm -rf "${workspace}"
}
trap 'on_exit' EXIT

pushd "${repository_path}" &> /dev/null || panic "unable to cd to ${repository_path}"

zip_path="${workspace}/${file_name}"

# shellcheck disable=SC2035  # glob will always be interpreted as file / dir names, not options
zip --quiet --recurse-paths "${zip_path}" .

cd "${workspace}" || panic "unable to cd to ${workspace}"
sha256sum "${file_name}" > "${file_name}.sha256sum"

popd &> /dev/null || panic "unable to cd back to original directory"

mv "${zip_path}" "${output_directory}"
mv "${zip_path}.sha256sum" "${output_directory}"

echo "Repository exported to ${output_directory}/${file_name}"
