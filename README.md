# Development environment

Personal machine setup for macOS, Linux, and Windows (WSL2). It installs the
latest release of every tool; nothing is pinned here. Start here on a new
machine; review [the recommendations](docs/recommendations.md) afterward.

| Platform | CLI and shell | Desktop apps |
| --- | --- | --- |
| macOS | Homebrew + zsh + Oh My Zsh | Homebrew casks in the Brewfile |
| Linux | Homebrew + zsh + Oh My Zsh | Choose distro-supported apps manually |
| Windows | Same Linux setup inside WSL2 | Windows Terminal and optional Windows apps |

## New machine

1. On macOS, run `xcode-select --install` for compiler tools. On Ubuntu/Debian,
   run `sudo apt update` then `sudo apt install build-essential procps curl file git`.
   Other Linux distributions need equivalent packages. On Windows, first follow
   [Windows setup](docs/windows.md).
2. Install Homebrew using the [official installation instructions](https://docs.brew.sh/Installation).
   Review the installer before running it, then execute the `brew shellenv` command
   it prints. This is required before bootstrap can find Homebrew.
3. Clone this repo into your owner directory:

   ```sh
   mkdir -p ~/repos/juanatjcx
   git clone https://github.com/juanatjcx/dev-environment.git ~/repos/juanatjcx/dev-environment
   cd ~/repos/juanatjcx/dev-environment
   bash scripts/bootstrap.sh
   ```

4. Open a new terminal. On Linux/WSL, optionally set zsh as your login shell:
   run `command -v zsh`, ensure that exact path is listed in `/etc/shells` (an
   administrator may need to add it), then run `chsh -s "$(command -v zsh)"`.
   Bootstrap does not change your login shell.
5. Configure directory-specific Git identities using [account setup](docs/accounts.md). Run
   `bash scripts/doctor.sh` and `nvm --version` in the new terminal.

The scripts are executable bash scripts, so `./scripts/bootstrap.sh` works as
well as `bash scripts/bootstrap.sh`.

Bootstrap installs packages (and may upgrade existing packages), clones missing
Oh My Zsh/plugin repositories, and installs shell files. It leaves existing plugin
directories intact. Fresh plugin clones use current upstream defaults, not pinned
commits. Shell installation copies files and backs up previous files under
`~/.dev-environment-backup.*`; rerun it after editing this repo. It does not clone
your other repositories or configure cloud credentials.

The [root Brewfile](Brewfile) is the single list of what gets installed: the CLI
tools shared by every platform, plus [macOS apps](#macos-apps) as casks. macOS
uses its supplied Git and zsh; Homebrew Vim adds debugger support. Linux/WSL
installs Git and zsh explicitly. Homebrew always installs the current release.
Pin runtimes and dependencies inside individual projects instead (`.nvmrc`,
`global.json`, lockfiles).

## Shell and repositories

```text
~/repos/
  juanatjcx/       personal repositories
  juanmicrosoft/  work repositories
  experimental/   disposable experiments
```

Keep this existing convention. `repos` navigates to the root, `myrepos` to your
personal owner directory, and `repo <name>` has directory completion. To adapt
another machine, add overrides to `~/.zshrc.local`:

```sh
export REPOS_OWNER="your-github-owner"
export MY_REPOS="$HOME/repos/$REPOS_OWNER"
export EDITOR="vim"
```

The tracked configuration retains your two-line developer prompt, git status,
autosuggestions, syntax highlighting, directory jumping, 50,000 history entries,
and arrow-key history search. It adds OS-aware plugins, user-cache storage,
update reminders, nvm initialization, explicit history widgets, fzf integration, and automatic `.nvmrc` switching. Personal
configuration belongs in `~/.zshrc.local` or `~/.zprofile.local`, never in tracked
files. History ignores commands beginning with a space; this is convenience,
not a credential protection mechanism.

For shell-only installation on this machine:

```sh
bash scripts/install-shell.sh
```

To roll back, copy the backup's `zshrc`, `zprofile` (if present), and
`developer.zsh-theme`, and `vimrc` (if present) to their original paths. If `.zprofile` did not previously
exist, remove the newly installed one. The backup preserves symlinks.

## Git and accounts

Set identity on each machine; no email or credential files are copied:

```sh
git config --global user.name "Your Name"
git config --global user.email "your-verified-email"
git config --global init.defaultBranch main
gh auth login
gh auth setup-git
gh auth status
```

The GitHub CLI provides [Git authentication setup](https://cli.github.com/manual/gh_auth).
For your personal/work identities, run `bash scripts/setup-git.sh PERSONAL_EMAIL WORK_EMAIL`; see [accounts](docs/accounts.md), which also covers separate Google Cloud and Firebase accounts. Select identities deliberately before your first commit. Authenticate
AWS, Azure, Google Cloud and Firebase only when needed, using your organization's approved
SSO/login workflow; never commit their credentials or copied home directories.

## Maintenance

- Update everything with `brew update && brew upgrade --greedy`. `--greedy`
  also upgrades apps that update themselves (Chrome, Docker Desktop, gcloud),
  which a plain `brew upgrade` skips.
- Run `omz update`; update external plugins separately if they are Git clones.
  Plugin directories on the original Mac are not standalone Git checkouts, so
  do not assume `git pull` there will update them.
- To add a tool, install it with Homebrew and add it to the Brewfile.
- A Docker Desktop copied in manually has no Homebrew receipt, so
  `brew bundle check` fails on it and bootstrap is expected to stop. Adopt it
  rather than reinstalling; see
  [adopting a manually installed app](docs/containers.md#adopting-a-manually-installed-app).
- Avoid `brew bundle cleanup --force` with this repo; unrelated packages may
  be removed. The bootstrap never performs cleanup.

Validation performed locally: Bash/zsh syntax, Ruby Brewfile syntax, isolated
shell install/reinstall with backups, and interactive shell startup. Linux/WSL
package installation requires verification on those systems.

Bootstrap initializes Node LTS and installs Vim language tooling. See
[the editor guide](docs/editor.md), [Python workflow](docs/python.md),
[container guidance](docs/containers.md), and [recovery/Xcode steps](docs/recovery.md).

## macOS apps

The Brewfile installs these casks on macOS only. To add one to an existing Mac
without rerunning bootstrap, run `brew install --cask <name>`.

- **Docker Desktop** (`docker-desktop`): containers; see
  [container guidance](docs/containers.md).
- **Google Chrome** (`google-chrome`): web development and browser testing. On
  Linux/WSL, install Chrome from Google's distro packages if needed.
- **Google Cloud CLI** (`gcloud-cli`): `gcloud`, `gsutil` and `bq`. On Linux/WSL,
  use [Google's package repositories](https://cloud.google.com/sdk/docs/install).
  Sign in with `gcloud auth login` and, for local application credentials,
  `gcloud auth application-default login`. The Firebase CLI (`firebase-cli`) is
  a formula, installed on every platform; sign in with `firebase login`.
  Components added with `gcloud components install` land in
  `$HOMEBREW_PREFIX/share/google-cloud-sdk/bin`, which the shell adds to `PATH`.
  Update with `brew upgrade --greedy` rather than `gcloud components update`, so
  Homebrew's record stays in step and a later cask upgrade does not overwrite
  the SDK.
- **Raspberry Pi Imager** (`raspberry-pi-imager`): writes Raspberry Pi OS and
  other images to microSD cards and USB drives. On Linux, use the
  [official download](https://www.raspberrypi.com/software/) or your
  distribution's package; WSL usually cannot write to removable drives, so image
  cards from Windows instead.
- **Others**: 1Password, ChatGPT, Claude, Claude Code, Codex and Ghostty.
