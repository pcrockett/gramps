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

test ! -f "${readme_path}" || echo "WARNING: README.md already exists."

private_key="$(
    age-keygen 2> /dev/null | grep --perl-regexp --only-matching '(?<=^AGE-SECRET-KEY-1).+$'
)"

echo "AGE-SECRET-KEY-1${private_key}" | age-keygen -y > "${pubkey_path}"

readme_content() {
    echo "# Gramps Pseudo-Offline Backup"
    echo
    echo "This is a [gramps](https://github.com/pcrockett/gramps) archive. \`gramps\` is just a Bash script"
    echo "wrapper for the [age](https://github.com/FiloSottile/age) encryption tool."
    echo
    echo "Any files you see here are encrypted with this public key:"
    echo
    echo "    $(cat "${pubkey_path}")"
    echo
    echo "The private key has been written down <!-- TODO: where did you write down your private key? -->"
    echo
    echo "When you have the private key, you can decrypt files with the command:"
    echo
    echo "    gramps decrypt [the_encrypted_file] [the_decrypted_file]"
    echo
}

readme_content > "${readme_path}"

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
