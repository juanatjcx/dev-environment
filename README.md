# Development environment

Personal machine setup for macOS, Linux, and Windows (WSL2). Tools install at
their latest release, except that nvm's default Node is the latest LTS, the Vim
tooling keeps TypeScript on 6.x, and the Node debug adapter follows Vimspector's
own choice (see [the editor guide](docs/editor.md)). See
[Maintenance](#maintenance) to update everything. This is a development
baseline, not a full machine backup: apps installed outside the Brewfile are not
covered. Start here on a new machine; review [the
recommendations](docs/recommendations.md) afterward.

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

`doctor.sh` fails when a tool or Brewfile entry is missing. It also checks the
projects under `~/repos` (Node pins, .NET SDK pins, Docker when a project uses
it), the selected Xcode, Touch ID for sudo, the SSH agent and which Git
identities sign commits, and the Claude Code plugins, and prints a warning for
each problem without failing.

The scripts are executable bash scripts, so `./scripts/bootstrap.sh` works as
well as `bash scripts/bootstrap.sh`.

Bootstrap installs packages (and may upgrade existing packages), clones missing
Oh My Zsh/plugin repositories and fast-forwards existing Git checkouts of them,
and installs shell files. Clones use current upstream defaults, not pinned
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
`developer.zsh-theme`, and `vimrc` (if present) to their original paths; for
Git, copy `shared.gitconfig` and `git-ignore` back to `~/.config/git/` as
`shared.gitconfig` and `ignore`, or remove the `include.path` line from
`~/.gitconfig`. If `.zprofile` did not previously
exist, remove the newly installed one. The backup preserves symlinks.

## Git and accounts

Set identity on each machine; no email or credential files are copied:

```sh
git config --global user.name "Your Name"
git config --global user.email "your-verified-email"
gh auth login
gh auth setup-git
gh auth status
```

The GitHub CLI provides [Git authentication setup](https://cli.github.com/manual/gh_auth).
For your personal/work identities, run `bash scripts/setup-git.sh PERSONAL_EMAIL WORK_EMAIL`; see [accounts](docs/accounts.md), which also covers commit signing with 1Password and separate Google Cloud and Firebase accounts. Select identities deliberately before your first commit. Authenticate
AWS, Azure, Google Cloud and Firebase only when needed, using your organization's approved
SSO/login workflow; never commit their credentials or copied home directories.

Shared Git preferences live in [`git/gitconfig`](git/gitconfig) and global
ignores in [`git/ignore`](git/ignore). Shell installation copies them to
`~/.config/git/` (backing up the previous files) and adds an `include.path` for
the preferences to `~/.gitconfig` once. They set Vim as the editor and `main`
as the first branch, create the remote branch on the first push, refuse to
merge on `git pull` when histories diverge (rebase or merge deliberately),
prune deleted remote branches on fetch, and show the common ancestor in
conflicts. Because the include comes last in `~/.gitconfig`, these win over
the same settings made there with `git config --global`; change them in
`git/gitconfig` instead, or per repository with `git config`. Personal ignores
for one project go in its `.git/info/exclude`.

## SSH

Bootstrap runs `scripts/setup-ssh.sh`, which installs `~/.ssh/config` so SSH
uses the 1Password SSH agent (turn it on in 1Password: Settings → Developer).
Keys stay in 1Password and are approved there. Personal hosts go in
`~/.ssh/config.local`, which is read first, so its settings win; it is never
replaced. The first run moves an existing hand-written `~/.ssh/config` there
and keeps a copy under `~/.dev-environment-backup.*`; later runs replace
`~/.ssh/config` itself, keeping a copy if it was edited, so tools that add
lines there (an `Include` from OrbStack or `gcloud compute config-ssh`, for
example) belong in `config.local` instead. When 1Password is not
installed, the config has no agent and SSH uses its defaults. On WSL, use the
1Password agent from Windows through `ssh.exe` instead; see 1Password's WSL
guide.

## Maintenance

- Update everything with `brew update && brew upgrade --greedy`, then rerun
  `scripts/bootstrap.sh`. `--greedy` also upgrades apps that update themselves
  (most casks here, such as Chrome, Docker Desktop and gcloud), which a plain
  `brew upgrade` skips. Bootstrap then fast-forwards Oh My Zsh and the zsh and
  Vim plugin checkouts, installs the latest Node LTS, updates the Vim language
  servers and debugger, and updates the [Claude Code
  plugins](#claude-code-plugins). It also replaces `~/.zshrc`, `~/.zprofile`,
  `~/.vimrc` and the Oh My Zsh `developer` theme with the repo's copies, backing
  up the old ones under `~/.dev-environment-backup.*`; keep local changes in the
  `*.local` files. Old backups can be deleted.
- Plugin directories installed without Git are not checkouts, so bootstrap
  leaves them as they are; replace them with a fresh clone to keep them current.
- To add a tool, install it with Homebrew and add it to the Brewfile.
- A Docker Desktop copied in manually has no Homebrew receipt, so
  `brew bundle check` fails on it and bootstrap is expected to stop. Adopt it
  rather than reinstalling; see
  [adopting a manually installed app](docs/containers.md#adopting-a-manually-installed-app).
- A Mac App Store copy of Tailscale also has no Homebrew receipt, and Homebrew
  would install the standalone build next to it, which Tailscale warns against.
  Before running bootstrap on such a Mac, quit Tailscale, drag it from
  Applications to the Trash (this asks for your password), empty the Trash and
  restart the Mac. To run bootstrap before switching, prefix it with
  `HOMEBREW_BUNDLE_CASK_SKIP=tailscale-app`.
- Avoid `brew bundle cleanup --force` with this repo; unrelated packages may
  be removed. The bootstrap never performs cleanup.

Every push and pull request runs [checks](.github/workflows/check.yml):
ShellCheck on the scripts, zsh syntax, bash 3.2 syntax on macOS, and Homebrew
reading the Brewfile. Run `shellcheck scripts/*.sh` before committing. These are
static checks; they do not install anything, so Linux/WSL setup still needs
verification on those systems.

Bootstrap initializes Node LTS and installs Vim language tooling. See
[the editor guide](docs/editor.md), [Python workflow](docs/python.md),
[container guidance](docs/containers.md), and
[recovery/Xcode steps](docs/recovery.md).

## macOS apps

The Brewfile installs these apps on macOS only. To add a cask to an existing
Mac without rerunning bootstrap, run `brew install --cask <name>`.

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
- **Tailscale** (`tailscale-app`): private network between your machines. This
  is Tailscale's standalone build, not the Mac App Store one, and the two must
  not be installed together; see [Maintenance](#maintenance) for switching. On first launch,
  approve its system extension and VPN configuration when macOS asks, then sign
  in. The app provides the `tailscale` CLI, so do not also install the
  `tailscale` formula. On Linux, use
  [Tailscale's install instructions](https://tailscale.com/download/linux);
  under WSL, install the Windows app on the host instead of inside WSL.
- **Others**: 1Password, ChatGPT, Claude, Claude Code, Codex and Ghostty.
- **Mac App Store apps** (through `mas`): 1Password for Safari, Developer
  (Apple's developer app) and Magnet (window snapping). Sign in to the App
  Store with the Apple Account that owns Magnet before bootstrap, since `mas`
  cannot sign in for you, and expect a password prompt when it installs or
  updates one. If an App Store install fails, `brew bundle` fails and bootstrap
  stops; to run it without them, prefix bootstrap with
  `HOMEBREW_BUNDLE_MAS_SKIP="1569813296 640199958 441258766"`. Other App Store apps on
  a Mac are personal and are not listed. Xcode also comes from the App Store but
  is installed by hand; see [recovery/Xcode steps](docs/recovery.md).

## Touch ID for sudo

On macOS, bootstrap runs `scripts/setup-sudo.sh`, which lets `sudo` accept
Touch ID. It enables the `pam_tid.so` line in `/etc/pam.d/sudo_local`, the file
Apple provides for local changes that survive macOS updates. A new file starts
from Apple's `sudo_local.template`; in an existing file, other entries are kept
and the line goes after any `pam_reattach` entry, which must come first. Writing
the file asks for your password once; later runs see it enabled and change
nothing. The password still works where Touch ID cannot be used, such as over
SSH or with no fingerprint enrolled. Inside tmux or screen, Touch ID does not
prompt and sudo falls back to the password unless you set up `pam_reattach`.
To undo it, comment out the `pam_tid.so` line with
`sudo vim /etc/pam.d/sudo_local` (the file is read-only, so save with `:w!`).

## macOS settings

On macOS, bootstrap runs `scripts/setup-macos.sh`, which sets:

- **Finder:** file extensions, hidden files, path bar and status bar shown;
  folders sorted first; searches cover the current folder; no warning when
  changing an extension.
- **Typing:** automatic capitalization, smart quotes and dashes, double-space
  period and autocorrect turned off, since they change code and commands.
- **Keyboard:** fast key repeat with a short delay; holding a key repeats it
  instead of showing the accent menu.
- **Screenshots:** saved to `~/Screenshots` instead of the Desktop.

It writes only values that differ and restarts Finder or the screenshot service
only when one of theirs changed. Keyboard and typing settings reach every app
after you log out and back in. To change one later, edit the script and rerun
it; to restore Apple's default, run `defaults delete <domain> <key>` with the
names from the script.

## Claude Code plugins

[`claude/plugins.txt`](claude/plugins.txt) lists the Claude Code plugins to
install at user scope, as `plugin@marketplace`, and
[`claude/marketplaces.txt`](claude/marketplaces.txt) lists the extra
marketplaces they come from. Bootstrap runs `scripts/setup-claude.sh`, which
adds missing marketplaces, installs missing plugins and updates installed ones
to the latest version. It keeps going past a failed plugin and reports the
failure at the end. It never auto-approves a plugin that runs its own setup
command, so run bootstrap in a terminal, where it can ask you to confirm one.
Restart Claude Code to load updates. On Linux/WSL, install Claude Code yourself
first; bootstrap skips plugins until `claude` is on `PATH`.

To add a plugin, install it with `claude plugin install <plugin@marketplace>`
and add the same line to `claude/plugins.txt`. The script does not uninstall
plugins missing from the list. Plugins provided by your claude.ai account (for
example, product-management or engineering) sync when you sign in and are not
listed. The rest of `~/.claude/settings.json` (theme and other preferences) is
personal and stays out of this repo.
