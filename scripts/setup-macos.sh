#!/usr/bin/env bash
set -euo pipefail
# Apply developer-friendly macOS settings. Only values that differ are written,
# and Finder or the screenshot service restarts only when one of theirs changed.
[[ "$(uname -s)" == Darwin ]] || exit 0
changed=()

# set_default DOMAIN KEY TYPE VALUE; booleans are read back as 1/0.
set_default() {
  local domain="$1" key="$2" type="$3" value="$4" expected="$4"
  [[ "$type" == -bool ]] && { [[ "$value" == true ]] && expected=1 || expected=0; }
  [[ "$(defaults read "$domain" "$key" 2>/dev/null)" == "$expected" ]] && return 0
  defaults write "$domain" "$key" "$type" "$value"
  changed+=("$domain:$key")
}

# Finder: show extensions, hidden files, path and status bars; folders first;
# search the current folder; no warning when changing an extension.
set_default NSGlobalDomain AppleShowAllExtensions -bool true
set_default com.apple.finder AppleShowAllFiles -bool true
set_default com.apple.finder ShowPathbar -bool true
set_default com.apple.finder ShowStatusBar -bool true
set_default com.apple.finder _FXSortFoldersFirst -bool true
set_default com.apple.finder FXDefaultSearchScope -string SCcf
set_default com.apple.finder FXEnableExtensionChangeWarning -bool false

# Typing: no automatic text changes that break code and commands.
set_default NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
set_default NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
set_default NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
set_default NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
set_default NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Keyboard: fast repeat with a short delay; holding a key repeats it instead of
# showing the accent menu. These apply after logging out and back in.
set_default NSGlobalDomain KeyRepeat -int 2
set_default NSGlobalDomain InitialKeyRepeat -int 15
set_default NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Screenshots go to ~/Screenshots instead of the Desktop.
mkdir -p "$HOME/Screenshots"
set_default com.apple.screencapture location -string "$HOME/Screenshots"

if (( ${#changed[@]} == 0 )); then
  echo 'macOS settings are already applied.'
  exit 0
fi
case " ${changed[*]} " in *' com.apple.finder:'*|*':AppleShowAllExtensions '*) killall Finder 2>/dev/null || true ;; esac
case " ${changed[*]} " in *' com.apple.screencapture:'*) killall SystemUIServer 2>/dev/null || true ;; esac
echo 'macOS settings applied; log out and back in for the keyboard and typing settings to reach every app.'
