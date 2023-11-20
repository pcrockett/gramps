# shellcheck shell=bash

# shellcheck disable=SC2154  # variables like ${args} are defined in main script

repo_path="${args["--repo"]:-}"
if [ "${repo_path}" == "" ]; then
    repo_path="${GRAMPS_DEFAULT_REPO:-}"
fi
test "${repo_path}" != "" || panic "Must specify a repository path via --repo flag or GRAMPS_DEFAULT_REPO env variable."
repo_path="$(readlink --canonicalize "${repo_path}")"

out_file_name="${args["--filename"]:-}" 

input_path="${args[input_path]:-}"
if [ "${input_path}" == "" ]; then
    test "${out_file_name}" != "" || panic "Must specify --filename flag when no INPUT_PATH is specified."
elif [ "${out_file_name}" == "" ]; then
    out_file_name="$(basename "${input_path}")"
fi

output_path="$(readlink --canonicalize "${repo_path}/${out_file_name}.age")"
test ! -e "${output_path}" || panic "Already exists: ${output_path}"

gramps_dir="${repo_path}/.gramps"
test -d "${gramps_dir}" || panic "Not a gramps repository: ${repo_path}"

age_cmd=(
    age --encrypt --armor
    --recipients-file "${gramps_dir}/pubkey"
    --output "${output_path}"
)

if [ "${input_path}" == "" ]; then
    # reading from stdin
    "${age_cmd[@]}"
else
    test -f "${input_path}" || panic "File not found: ${input_path}"
    "${age_cmd[@]}" "${input_path}"
fi

(
    cd "${repo_path}" || panic "unable to cd into ${repo_path}"
    sha256sum "$(basename "${output_path}")" >> "${gramps_dir}/sha256sum"
)

echo "File saved at ${output_path}"
