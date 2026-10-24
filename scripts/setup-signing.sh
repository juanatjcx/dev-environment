#!/usr/bin/env bash
set -euo pipefail
# Sign commits and tags for one directory identity with an SSH key held in
# 1Password. The private key never leaves 1Password; Git only gets the public
# key, and 1Password asks you to approve signing.
if (( $# != 2 )); then
  echo 'Usage: bash scripts/setup-signing.sh ACCOUNT "1Password key name or ssh public key"' >&2
  echo 'Example: bash scripts/setup-signing.sh juanatjcx "Github JuanAtJcx"' >&2
  exit 2
fi
account="$1" key="$2"
config_dir="$HOME/.config/git"
file="$config_dir/$account.gitconfig"
[[ -f "$file" ]] || { echo "$file not found; run scripts/setup-git.sh first." >&2; exit 1; }

case "$(uname -s)" in
  Darwin)
    sign=/Applications/1Password.app/Contents/MacOS/op-ssh-sign
    agent="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ;;
  *)
    sign=/opt/1Password/op-ssh-sign
    agent="$HOME/.1password/agent.sock" ;;
esac
[[ -x "$sign" ]] || { echo "1Password's signing helper was not found at $sign." >&2; exit 1; }

# Accept a public key as is, or look the name up in the 1Password SSH agent.
if [[ "$key" != ssh-* ]]; then
  [[ -S "$agent" ]] || { echo 'Turn on the 1Password SSH agent (Settings → Developer).' >&2; exit 1; }
  name="$key"
  keys="$(SSH_AUTH_SOCK="$agent" ssh-add -L)" ||
    { echo 'Could not read keys from the 1Password SSH agent; is 1Password unlocked?' >&2; exit 1; }
  key="$(awk -v name="$name" '{ c = $3; for (i = 4; i <= NF; i++) c = c " " $i } c == name { print $1, $2; exit }' <<<"$keys")"
  [[ -n "$key" ]] || { echo "No key named \"$name\" in the 1Password SSH agent." >&2; exit 1; }
fi
read -r key_type key_data _ <<<"$key"
[[ -n "${key_data:-}" ]] || { echo 'That does not look like an SSH public key.' >&2; exit 1; }
email="$(git config --file "$file" user.email)"
[[ -n "$email" ]] || { echo "$file has no user.email; signing needs one." >&2; exit 1; }

git config --file "$file" gpg.format ssh
git config --file "$file" gpg.ssh.program "$sign"
git config --file "$file" user.signingkey "key::$key_type $key_data"
git config --file "$file" commit.gpgsign true
git config --file "$file" tag.gpgsign true
# Let git log --show-signature verify these commits locally.
signers="$config_dir/$account.allowed_signers"
printf '%s namespaces="git" %s %s\n' "$email" "$key_type" "$key_data" >"$signers"
git config --file "$file" gpg.ssh.allowedSignersFile "$signers"
echo "Commits and tags in $account repositories are now signed with that key."
echo 'GitHub shows them as Verified once the key is added there as a signing key.'
