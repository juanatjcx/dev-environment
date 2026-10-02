# Observed machine — 2026-10-02

- Apple Silicon Homebrew at `/opt/homebrew`.
- Direct formulas: awscli, azure-cli, dotnet, node, firebase-cli, gh, nvm.
- Casks: 1password, chatgpt, claude, claude-code, codex, ghostty.
- Oh My Zsh with custom `developer` theme and plugins git, z, macos,
  zsh-autosuggestions, zsh-syntax-highlighting.
- Existing shell set personal repos to `~/repos/juanatjcx`; work clones are under
  `~/repos/juanmicrosoft`, with `~/repos/experimental` for experiments.
- nvm was installed without initialization or a `~/.nvm` directory.
- Git resolved to `/usr/bin/git`; Python to `/usr/bin/python3` in the inspected
  noninteractive PATH. Homebrew Python is also installed as a dependency.
- Xcode.app was present with Command Line Tools initially selected. Xcode 27.0
  was subsequently selected and verified after the user completed setup.
- Node LTS v24.21.0 was subsequently installed via nvm and made the default.
- Docker Desktop was added to the desired macOS baseline after the initial capture;
  the original inventory remains a snapshot from before that installation.
- Other applications exist outside the Homebrew manifest. Their installation
  provenance and configuration were not captured; this is a development baseline,
  not a full machine backup.

No credentials, Git email, repository remotes, cloud profiles, or shell history
were copied. See `inventory/` for the package snapshot.
