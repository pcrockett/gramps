# shellcheck shell=bash

# shellcheck disable=SC2154  # variables like ${args} are defined in main script
directory_path="$(readlink --canonicalize "${args[directory_path]}")"
gramps_dir="${directory_path}/.gramps"
gramps_temp_dir="${gramps_dir}.tmp"
pubkey_path="${gramps_temp_dir}/pubkey"
readme_path="${directory_path}/README.md"

rm -rf "${gramps_temp_dir}"
mkdir -p "${gramps_temp_dir}"

test ! -d "${gramps_dir}" || panic "Already initialized: ${directory_path}"

test ! -f "${readme_path}" || echo "WARNING: README.md already exists"
touch "${readme_path}"

private_key="$(
    age-keygen 2> /dev/null | grep --perl-regexp --only-matching '(?<=^AGE-SECRET-KEY-1).+$'
)"

echo "AGE-SECRET-KEY-1${private_key}" | age-keygen -y > "${pubkey_path}"

# prepend a version number to private key for future-proofing
private_key="01${private_key}"

mv "${gramps_temp_dir}" "${gramps_dir}"

echo "Here is your private key. Write it down. You will need it to decrypt"
echo "files, however it will never be displayed again after this:"
echo "╭───────────────────────╮"
echo "│${private_key:0:5} ${private_key:5:5} ${private_key:10:5} ${private_key:15:5}│"
echo "│${private_key:20:5} ${private_key:25:5} ${private_key:30:5} ${private_key:35:5}│"
echo "│${private_key:40:5} ${private_key:45:5} ${private_key:50:5} ${private_key:55:5}│"
echo "╰───────────────────────╯"
