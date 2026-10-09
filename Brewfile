# Current CLI setup, shared by macOS and Homebrew on Linux/WSL.
brew "awscli"
brew "azure-cli"
brew "dotnet"
brew "node"
brew "firebase-cli"
brew "gh"
brew "nvm"
# Source navigation and explicit Python tooling.
brew "ripgrep"
brew "jq"
brew "fzf"
brew "uv"
# Python-enabled Vim is required for the debugger.
brew "vim"
# macOS supplies Git and zsh through its developer tools/OS.
unless OS.mac?
  brew "git"
  brew "zsh"
end

if OS.mac?
  cask "1password"
  cask "chatgpt"
  cask "claude"
  cask "claude-code"
  cask "codex"
  cask "ghostty"
  cask "google-chrome"
  cask "docker-desktop"
end
