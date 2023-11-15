# shellcheck shell=bash

# shellcheck disable=SC2154  # variables like ${args} are defined in main script
input_path="${args[input_path]:-}"

output_path="${args["--output"]}"
output_path="$(readlink --canonicalize "${output_path}")"
test ! -e "${output_path}" || panic "Already exists: ${output_path}"

gramps_dir="$(dirname "${output_path}")/.gramps"

test -d "${gramps_dir}" || panic "Not a gramps repository: ${gramps_dir}"

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

echo "File saved at ${output_path}"
