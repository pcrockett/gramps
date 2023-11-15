## gramps 👴

**work in progress:** proof of concept is there though.

simple, pseudo-offline backups using [age](https://github.com/FiloSottile/age) encryption.

### _pseudo_-offline?

_gramps_ is a simple way to generate a public / private key pair, where the private key is written
down on paper and the public key stays on whatever device(s) you own.

this makes it convenient to save random bits of data (think MFA recovery codes or password vault
backups), such that they can only be decrypted with your offline private key. this way it is much
safer to back them up alongside the rest of your less-sensitive backups.

### example

```bash
gramps init ~/Backup
# private key is displayed in human-friendly format
# write it down, because you'll never see it again!
# this also generates a README file for your future self

gramps encrypt --output ~/Backup/example-mfa-recovery-code.txt.age
# copy / paste your recovery codes into the prompt
# they will be saved encrypted in `example-mfa-recovery-code.txt.age`

gramps encrypt ~/Downloads/password-vault-export.json --output ~/Backup/password-vault.json.age
# json file will be encrypted, saved in `password-vault.json.age`
# optionally add `--shred` parameter to securely delete the unencrypted file when finished

gramps decrypt example-mfa-recovery-code.txt.age
# will prompt you for the private key you wrote down on paper
# type it in; decrypted file is then displayed on screen

gramps decrypt password-vault.json.age --output password-vault.json
# will prommpt you for the private key you wrote down on paper
# type it in; decrypted file is saved in `password-vault.json`

gramps zip ~/Backup > 2023-11-12-backup.zip
# packages up your Backup directory so you can dump it in a variety of places (cloud drive, etc.)
# (doesn't replace your automatic backup scheme)
```
