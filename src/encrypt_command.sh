# shellcheck shell=bash

# shellcheck disable=SC2154  # variables like ${args} are defined in main script

set_repo_path_arg from_option

out_file_name="${args["--filename"]:-}" 

input_path="${args[input_path]:-}"
if [ "${input_path}" == "" ]; then
    test "${out_file_name}" != "" || panic "Must specify --filename flag when no INPUT_PATH is specified."
elif [ "${out_file_name}" == "" ]; then
    out_file_name="$(basename "${input_path}")"
fi

output_path="$(readlink --canonicalize "${repository_path}/${out_file_name}.age")"
test ! -e "${output_path}" || panic "Already exists: ${output_path}"

gramps_dir="${repository_path}/.gramps"
test -d "${gramps_dir}" || panic "Not a gramps repository: ${repository_path}"

age_cmd=(
    age --encrypt --armor
    --recipients-file "${gramps_dir}/pubkey"
    --output "${output_path}.tmp"
)

on_exit() {
    rm -f "${output_path}.tmp"
}
trap 'on_exit' EXIT

if [ "${input_path}" == "" ]; then
    # reading from stdin
    prompt_if_interactive "Enter cleartext to be encrypted." "${age_cmd[@]}"
else
    test -f "${input_path}" || panic "File not found: ${input_path}"
    "${age_cmd[@]}" "${input_path}"
fi

mv "${output_path}.tmp" "${output_path}"

(
    cd "${repository_path}" || panic "unable to cd into ${repository_path}"
    sha256sum "$(basename "${output_path}")" >> .gramps/sha256sum
)

echo "File saved at ${output_path}"
