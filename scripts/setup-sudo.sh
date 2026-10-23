#!/usr/bin/env bash
set -euo pipefail
# Let sudo accept Touch ID on macOS. /etc/pam.d/sudo_local survives macOS
# updates, unlike /etc/pam.d/sudo; the password still works when Touch ID
# is unavailable (SSH, a closed lid, no enrolled finger).
[[ "$(uname -s)" == Darwin ]] || exit 0
local_file=/etc/pam.d/sudo_local
template=/etc/pam.d/sudo_local.template
line='auth       sufficient     pam_tid.so'
enabled() { grep -Eq '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so' "$1"; }

if [[ -f "$local_file" ]] && enabled "$local_file"; then
  echo 'Touch ID for sudo is already enabled.'
  exit 0
fi
grep -q 'include[[:space:]]*sudo_local' /etc/pam.d/sudo || {
  echo '/etc/pam.d/sudo does not include sudo_local; leaving sudo unchanged.' >&2
  exit 1
}
ls /usr/lib/pam/pam_tid.so* >/dev/null 2>&1 || {
  echo 'pam_tid is not available on this Mac; leaving sudo unchanged.' >&2
  exit 1
}

new="$(mktemp)"
trap 'rm -f "$new"' EXIT
if [[ -f "$local_file" ]]; then
  # Keep existing entries; Touch ID goes first so it is tried before them.
  { echo "$line"; cat "$local_file"; } >"$new"
elif [[ -f "$template" ]]; then
  sed -E 's/^#[[:space:]]*(auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so)/\1/' "$template" >"$new"
else
  printf '# sudo_local: local config file which survives system update and is included for sudo\n%s\n' "$line" >"$new"
fi
enabled "$new" || { echo 'Could not build the new sudo_local; leaving sudo unchanged.' >&2; exit 1; }

echo "Enabling Touch ID for sudo in $local_file (asks for your password)."
sudo install -m 444 -o root -g wheel "$new" "$local_file"
echo 'Touch ID for sudo is enabled; it applies to new sudo prompts.'
