#!/usr/bin/env bash
set -euo pipefail
# Install ~/.ssh/config so SSH uses the 1Password agent. Personal hosts live in
# ~/.ssh/config.local, which this file includes first so its settings win.
marker='# Installed by dev-environment (scripts/setup-ssh.sh); changes here are replaced.'
ssh_dir="$HOME/.ssh"
config="$ssh_dir/config"
local_config="$ssh_dir/config.local"

# The 1Password agent socket, when 1Password is installed. WSL uses the
# Windows agent through ssh.exe instead, so it gets no agent here.
# The ~ is literal on purpose: ssh expands it, which keeps the file portable.
agent=''
# shellcheck disable=SC2088
case "$(uname -s)" in
  Darwin)
    [[ ! -d /Applications/1Password.app ]] ||
      agent='~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock' ;;
  Linux)
    if ! grep -qi microsoft /proc/version 2>/dev/null && [[ -d /opt/1Password ]]; then
      agent='~/.1password/agent.sock'
    fi ;;
esac

new="$(mktemp)"
trap 'rm -f "$new"' EXIT
{
  echo "$marker"
  echo '# Put personal hosts in ~/.ssh/config.local; it is read first, so its settings win.'
  echo 'Include config.local'
  if [[ -n "$agent" ]]; then
    printf '\nHost *\n  IdentityAgent "%s"\n' "$agent"
  fi
} >"$new"

mkdir -p "$ssh_dir"
chmod 700 "$ssh_dir"
if [[ -f "$config" ]] && cmp -s "$new" "$config"; then
  echo 'SSH config is already up to date.'
  exit 0
fi
if [[ -e "$config" ]] && ! grep -qxF "$marker" "$config"; then
  # First run over a hand-written config: keep it as config.local.
  if [[ -e "$local_config" ]]; then
    echo "Both $config and $local_config exist; move your hosts into config.local, delete config and rerun." >&2
    exit 1
  fi
  backup="$(mktemp -d "$HOME/.dev-environment-backup.XXXXXXXX")"
  cp -p "$config" "$backup/ssh_config"
  mv "$config" "$local_config"
  chmod 600 "$local_config"
  echo "Moved your SSH config to $local_config (copy in $backup)."
fi
install -m 600 "$new" "$config"
echo "Installed $config${agent:+ with the 1Password SSH agent}."
