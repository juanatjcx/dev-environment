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
- Docker Desktop was absent at the initial capture; see the 2026-10-04 update.
- Other applications exist outside the Homebrew manifest. Their installation
  provenance and configuration were not captured; this is a development baseline,
  not a full machine backup.

No credentials, Git email, repository remotes, cloud profiles, or shell history
were copied. See `inventory/` for the package snapshot.

## Follow-up — 2026-10-03

- Mac Studio, M4 Max (14 cores), 36 GB memory; macOS 27.0.1.
- ripgrep, jq, and fzf installed independently through Homebrew.
- uv added as an explicit Python tool.
- Apple Git and system zsh remain the macOS baseline; Homebrew Vim adds
  Python support needed by Vimspector.
- Node 22.23.3 installed for jcxsoftware (including its API); Node 20.20.2
  installed for Calor's website to match its existing CI major.
- Node 24.21.0 remains the general default. Project entry follows `.nvmrc`.
- Vim native packages provide LSP, completion, and EditorConfig support.
- Vimspector adds Node debugging; Python debugging uses an isolated uv-managed
  Python 3.13 environment.

## Docker Desktop — 2026-10-04

- Installed Docker Desktop 4.93.0 (240920), Apple Silicon, in `/Applications/Docker.app`.
- Installation source: Homebrew-fetched Docker DMG, copied directly into Applications.
  This installation has no Homebrew cask receipt; `brew list --cask` does not capture it.
- Docker Engine/client 29.8.1; Compose 5.5.1; context `desktop-linux`.
- Login shell resolves Docker through `~/.docker/bin/docker`.
- Verified client/server connectivity, `docker compose version`, and a successful
  `docker run --rm hello-world` (Linux ARM64 container).
- Docker Desktop is now included in the desired macOS baseline; `Brewfile.containers`
  remains available for a targeted installation on another machine.
- See `inventory/docker-desktop.txt` for the version/provenance snapshot.

## Google Cloud CLI — 2026-10-17

- Installed the `gcloud-cli` cask: Google Cloud SDK 589.0.0, bq 2.1.40.
  `gcloud info` showed it running on Homebrew's Python 3.14
  (`/opt/homebrew/bin/python3.14`). The cask depends on python@3.13 and its
  gcloud virtualenv was absent, so a reinstall may switch interpreters.
  `gcloud` resolves to `/opt/homebrew/bin/gcloud`.
- Firebase CLI 15.34.0 (`firebase-cli` formula) was already installed.
- gcloud-cli is now included in the desired macOS baseline. No gcloud or Firebase
  credentials or configurations were captured.
