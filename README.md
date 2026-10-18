# Development environment

Personal machine setup for macOS, Linux, and Windows (WSL2). The package baseline
was captured on **2026-10-02** from an Apple Silicon Mac. Start here on a new
machine; review [the recommendations](docs/recommendations.md) afterward.

| Platform | CLI and shell | Desktop apps |
| --- | --- | --- |
| macOS | Homebrew + zsh + Oh My Zsh | Captured Homebrew casks |
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

The [root Brewfile](Brewfile) is the portable desired setup: the observed CLI tools
plus source navigation and uv. macOS uses its supplied Git and zsh; Homebrew Vim adds debugger support.
Linux/WSL installs those tools explicitly. [The original Brewfile](inventory/Brewfile.macos)
preserves the observed package selection, while [the version inventory](inventory/homebrew-versions.txt)
records installed dependencies and versions for troubleshooting. These inventories
are snapshots, not version locks. Homebrew installs available releases;
[Homebrew's version model](https://docs.brew.sh/FAQ) does not guarantee arbitrary
historical versions. Pin runtimes and dependencies inside individual projects.

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

- Review `brew outdated`, then run `brew update` and `brew upgrade` when ready.
- Run `omz update`; update external plugins separately if they are Git clones.
  Existing plugin directories on the captured machine are not standalone Git
  checkouts, so do not assume `git pull` there will update them.
- To refresh the observed snapshot, run
  `brew bundle dump --file=inventory/Brewfile.macos --force` on macOS and
  `brew list --versions > inventory/homebrew-versions.txt`. Review the diff and
  update the portable Brewfile deliberately.
- On the captured Mac, `brew bundle check` reports `docker-desktop` as missing
  and bootstrap is expected to stop at the bundle step. Docker Desktop was installed without
  a Homebrew receipt. Run either command with
  `HOMEBREW_BUNDLE_CASK_SKIP=docker-desktop`; see
  [the known issue](docs/containers.md#known-issue-no-homebrew-cask-receipt).
- Avoid `brew bundle cleanup --force` with this repo; unrelated packages may
  be removed. The bootstrap never performs cleanup.

Validation performed locally: Bash/zsh syntax, Ruby Brewfile syntax, isolated
shell install/reinstall with backups, and interactive shell startup. Linux/WSL
package installation requires verification on those systems.

Bootstrap initializes Node LTS and installs Vim language tooling. See
[the editor guide](docs/editor.md) and [Python workflow](docs/python.md).
Docker Desktop is included in the macOS baseline and was verified locally on
2026-10-04. See [container guidance](docs/containers.md) for installation provenance
and checks, and [recovery/Xcode steps](docs/recovery.md).

Google Chrome (`cask "google-chrome"`) was added to the macOS baseline on
2026-10-09 for web development and browser testing; Google Chrome 155.0.8059.40
was installed with Homebrew. Chrome updates itself, so `brew upgrade` usually
skips it. To install it on an existing machine without rerunning bootstrap, run
`brew install --cask google-chrome`. On Linux/WSL, install Chrome from Google's
distro packages if needed.

The Google Cloud CLI (`cask "gcloud-cli"`) was added to the macOS baseline on
2026-10-17; Google Cloud SDK 589.0.0 (`gcloud`, `gsutil`, `bq`) was installed with
Homebrew. Firebase CLI (`brew "firebase-cli"`) was already part of the baseline.
To install gcloud on an existing machine, run `brew install --cask gcloud-cli`;
on Linux/WSL, use [Google's package repositories](https://cloud.google.com/sdk/docs/install).
Sign in with `gcloud auth login` and, for local application credentials,
`gcloud auth application-default login`; use `firebase login` for Firebase.
Components added with `gcloud components install` land in
`$HOMEBREW_PREFIX/share/google-cloud-sdk/bin`, which the shell adds to `PATH`.
