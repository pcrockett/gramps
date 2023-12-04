## gramps 👴

a simple, pseudo-offline backup tool using [age](https://github.com/FiloSottile/age) encryption.

to be clear, _gramps_ isn't so much of a _backup_ program, per say. it's more of a really
easy-to-use encryption tool that was built to safeguard especially sensitive data that you would
otherwise want to keep backed up completely offline (think MFA recovery codes or password vault
backups). it gives you a kind of _pseudo_-offline backup.

_disclaimer: gramps is suitable for MFA recovery codes, not nuclear launch codes._

### _pseudo_-offline?

_gramps_ is really just a simple way to generate a public / private key pair where the private key
is written down on paper and the public key stays on whatever device(s) you own. this makes it
super easy to encrypt information such that it can only be decrypted with your offline private key.

in other words, it gives you a backup that is super easy to add to (and maintain) over time, but
then requires a person to have physical access to a piece of paper if they want to actually get any
data out of it.

so yes, your _encrypted_ data remains technically online, but it achieves _almost_ the same security
benefits as a completely offline backup.

<details>
<summary>
<em>"if you need offline backups, why don't you just make your backups <strong>fully</strong> offline?"</em>
</summary>
<br>

there are a few reasons to avoid normal 100% offline backups. off the top of my head:

1. "offline" in this sense usually means "on an air-gapped or powered-off device." these devices
    require maintenance and regular checks to make sure they're still working or their storage
    isn't corrupted. _and you can't easily automate those tasks._ you have to depend on unreliable
    human meat bags to do that regular maintenance.
2. fully-offline backup data is hard to keep up-to-date. you _know_ your future self will rarely
    find the time to deal with the hassle of updating a fully-offline backup. there's not much point
    in restoring an offline backup when the information it contains is no longer relevant.

on the other hand, if the only offline bit of data is your decryption key on a piece of paper,
maintenance isn't any more difficult than regular run-of-the-mill backup maintenance. testing your
offline-ish backup looks the same as testing an online backup, with the additional step of going to
your sock drawer to dig out your private key, and entering it into the terminal to make sure it
still decrypts your files, which is probably about 2 minutes of additional effort.
</details>

<details>
<summary>
<em>"this is a bad idea; someone will find a flaw in the way age does encryption, and then your backups will be compromised."</em>
</summary>
<br>

yup. this isn't about keeping your data confidential _forever_. it's about adding a layer of
security to more sensitive stuff that will _probably_ be effective for the next few years. if
you're afraid someone will keep your data around until the encryption is broken, you should do some
things like rotate your MFA recovery codes and change your passwords. then create a new backup with
more advanced cryptography.

</details>

### example usage

first, pick a directory where you want to keep your _gramps_ repository:

```bash
export GRAMPS_DEFAULT_REPO=~/backup

gramps init
# Here is your private key. Write it down. You will need it to decrypt
# files, however it will never be displayed again after this:
# ╭───────────────────────╮
# │XXXXX XXXXX XXXXX XXXXX│
# │XXXXX XXXXX XXXXX XXXXX│
# │XXXXX XXXXX XXXXX XXXXX│
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
# .gramps/pubkey: OK
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

### installation

_official Linux support only._ PRs welcome for other OSes.

* install [age](https://github.com/FiloSottile/age)
* drop the [gramps script](./gramps) into a bin directory on your `PATH`

### contributing

_PRs, suggestions, and issues welcome._

this project uses [bashly](https://bashly.dannyb.co/) to build the script,
[shellcheck](https://github.com/koalaman/shellcheck/) for linting, and
[bats](https://github.com/bats-core/bats-core) for tests.

if `make` runs, you're ready for some dev work.
