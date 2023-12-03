## gramps 👴

simple, pseudo-offline backup tool using [age](https://github.com/FiloSottile/age) encryption.

_this is a new tool. after a 1.0 release i'll start making some backward-compatibility guarantees._

### _pseudo_-offline?

_gramps_ is a simple way to generate a public / private key pair, where the private key is written
down on paper and the public key stays on whatever device(s) you own. this makes it convenient to
save random bits of data (think MFA recovery codes or password vault backups), such that they can
only be decrypted with your offline private key.

so yes, your _encrypted_ data remains technically online (on your devices and in your backups),
but the key to decrypt that data is offline (paper), which is a significant layer of security for
your most sensitive, least-accessed bits of data.

### but why?

_if you need offline backups, why don't you just make your backups **fully** offline?_

there are a few reasons to avoid fully-offline backups, actually. off the top of my head:

1. "offline" in this sense usually means "on an air-gapped or powered-off device." these devices
    require maintenance and regular checks to make sure they're still working or their storage
    isn't corrupted. _and you can't easily automate those tasks._ you have to depend on unreliable
    human meat bags to do that regular maintenance.
2. fully-offline backup data is hard to keep up-to-date. offline backups aren't terribly useful if
    they are rarely up-to-date. and you _know_ your future self will rarely find the time to deal
    with the hassle of updating a fully-offline backup.

on the other hand, if the only fully-offline bit of data is your decryption key on a piece of paper,
updating your backed-up data is trivial. and it's unlikely you'll have problems maintaining it over
the next few _decades_ (depending on the type of paper and pen used, i guess).

maintenance for a partial offline backup looks like this:

1. check your checksums (with `gramps check`)
2. _do you know where your key is?_ yup, found it.
3. _is it still legible?_ yup.

it's also wise to periodically do a "full restore" test: _can you still decrypt a file with the
paper key?_ that's the hardest part, and usually takes about a minute of effort (typing in the
private key).

### installation

_official Linux support only._ PRs welcome for other OSes.

* install [age](https://github.com/FiloSottile/age)
* drop the [gramps script](./gramps) into a bin directory on your `PATH`

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

### contributing

_PRs, suggestions, and issues welcome._

this project uses [bashly](https://bashly.dannyb.co/) to build the script,
[shellcheck](https://github.com/koalaman/shellcheck/) for linting, and
[bats](https://github.com/bats-core/bats-core) for tests.

if `make` runs, you're ready for some dev work.
