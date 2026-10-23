#!/usr/bin/env bash
set -euo pipefail
# Let sudo accept Touch ID on macOS. /etc/pam.d/sudo_local survives macOS
# updates, unlike /etc/pam.d/sudo; the password still works when Touch ID
# is unavailable (SSH, no enrolled finger, no Touch ID sensor).
[[ "$(uname -s)" == Darwin ]] || exit 0
local_file=/etc/pam.d/sudo_local
template=/etc/pam.d/sudo_local.template
line='auth       sufficient     pam_tid.so'
tid='auth[[:space:]]+sufficient[[:space:]]+([^[:space:]]*/)?pam_tid\.so'
enabled() { grep -Eq "^[[:space:]]*$tid" "$1"; }

if [[ -f "$local_file" ]] && enabled "$local_file"; then
  echo 'Touch ID for sudo is already enabled.'
  exit 0
fi
grep -Eq '^[[:space:]]*auth[[:space:]]+include[[:space:]]+sudo_local' /etc/pam.d/sudo || {
  echo '/etc/pam.d/sudo does not include sudo_local; leaving sudo unchanged.' >&2
  exit 1
}
ls /usr/lib/pam/pam_tid.so* >/dev/null 2>&1 || {
  echo 'pam_tid is not available on this Mac; leaving sudo unchanged.' >&2
  exit 1
}

new="$(mktemp)"
trap 'rm -f "$new" "$new.tmp"' EXIT
if [[ -f "$local_file" ]]; then
  source_file="$local_file"
elif [[ -f "$template" ]]; then
  source_file="$template"
else
  source_file=/dev/null
  echo '# sudo_local: local config file which survives system update and is included for sudo' >"$new"
fi
# Uncomment an existing pam_tid line, keeping every other entry as it is.
sed -E "s|^#[[:space:]]*($tid)|\1|" "$source_file" >>"$new"
if ! enabled "$new"; then
  # pam_reattach (for tmux) must come before pam_tid, so add the line after
  # the last pam_reattach entry, or before everything else when there is none.
  awk -v line="$line" '
    { lines[NR] = $0 }
    /^[[:space:]]*auth.*pam_reattach/ { after = NR }
    END {
      if (!after) print line
      for (i = 1; i <= NR; i++) { print lines[i]; if (i == after) print line }
    }' "$new" >"$new.tmp"
  mv "$new.tmp" "$new"
fi
enabled "$new" || { echo 'Could not build the new sudo_local; leaving sudo unchanged.' >&2; exit 1; }

echo "Enabling Touch ID for sudo in $local_file (asks for your password)."
sudo install -m 444 -o root -g wheel "$new" "$local_file"
echo 'Touch ID for sudo is enabled; it applies to new sudo prompts.'
