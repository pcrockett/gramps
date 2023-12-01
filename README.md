## gramps 👴

simple, pseudo-offline backups using [age](https://github.com/FiloSottile/age) encryption.

### _pseudo_-offline?

_gramps_ is a simple way to generate a public / private key pair, where the private key is written
down on paper and the public key stays on whatever device(s) you own.

this makes it convenient to save random bits of data (think MFA recovery codes or password vault
backups), such that they can only be decrypted with your offline private key. this way it is much
safer to back them up alongside the rest of your less-sensitive backups.

### example usage

first, pick a directory where you want to keep your _gramps_ repository:

```bash
export GRAMPS_DEFAULT_REPO=~/backup

gramps init
# Here is your private key. Write it down. You will need it to decrypt
# files, however it will never be displayed again after this:
# ╭───────────────────────╮
# │01SYN 8DX4J 4SSJ5 YRM5N│
# │THAE5 W235Q CKAT6 Y8GAE│
# │PNSK5 9FS34 QZFQ9 3XM8R│
# ╰───────────────────────╯
```

now run `gramps encrypt` to save an encrypted copy of a file to your _gramps_ repo:

```bash
gramps encrypt ~/Downloads/bitwarden-vault-export.json
# File saved at /home/phil/backup/bitwarden-vault-export.json.age
```

it also works with stdin:

```bash
gramps encrypt --filename bitwarden-mfa-secret.txt
# Enter cleartext to be encrypted. Press Ctrl + D when finished.
# [copy / paste secret here]
# File saved at /home/phil/backup/bitwarden-mfa-secret.txt.age
```

[bit rot](https://en.wikipedia.org/wiki/Data_degradation) happens; if your file system doesn't
detect corruption, it's a good idea to run `gramps check` on a regular basis:

```bash
gramps check
# bitwarden-vault-export.json.age: OK
# bitwarden-mfa-secret.txt.age: OK
```

to decrypt, you will need the private key, which you hopefully wrote down:

```bash
gramps decrypt ~/backup/bitwarden-vault-export.json.age ./bitwarden-vault-export.json
# Enter private key. Press Ctrl + D when finished.
# [type out private key here]
# File saved at ./bitwarden-vault-export.json
```

it's ideal if your _gramps_ repo is automatically backed up. however if you just want to throw it
on a cloud drive of some sort, you can export your _gramps_ repo to zip file along with a checksum.

```bash
gramps export .
# Repository exported to ./backup_2023-12-01-1658.zip

sha256sum --check ./backup_2023-12-01-1658.zip.sha256sum
# backup_2023-12-01-1658.zip: OK
```
