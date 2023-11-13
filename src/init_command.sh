# shellcheck shell=bash

# shellcheck disable=SC2154  # variables like ${args} are defined in main script
directory_path="$(readlink --canonicalize "${args[directory_path]}")"
pubkey_path="${directory_path}/.pubkey"
readme_path="${directory_path}/README.md"

test ! -f "${pubkey_path}" || panic "Already initialized: ${directory_path}"
touch "${pubkey_path}"

test ! -f "${readme_path}" || echo "WARNING: README.md already exists"
touch "${readme_path}"
