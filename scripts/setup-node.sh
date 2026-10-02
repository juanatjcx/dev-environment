#!/usr/bin/env bash
set -euo pipefail
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
mkdir -p "$NVM_DIR"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  nvm_script="$NVM_DIR/nvm.sh"
else
  nvm_script="$(brew --prefix)/opt/nvm/nvm.sh"
fi
[[ -s "$nvm_script" ]] || { echo 'Install nvm first.' >&2; exit 1; }
# nvm is not guaranteed to support nounset in every release.
set +u
source "$nvm_script"
nvm install --lts
nvm alias default 'lts/*'
nvm use default
node --version
