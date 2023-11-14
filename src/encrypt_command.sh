# shellcheck shell=bash

# shellcheck disable=SC2154  # variables like ${args} are defined in main script
input_path="${args[input_path]}"
input_path="$(readlink --canonicalize "${input_path}")"
output_path="${args["--output"]}"
output_path="$(readlink --canonicalize "${output_path}")"

test -f "${input_path}" || panic "File not found: ${input_path}"

panic "Not a gramps directory: ${output_path}"
