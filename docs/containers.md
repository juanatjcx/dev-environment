# Container workflow

Use Docker Desktop on macOS and Windows; use native Docker Engine with the Compose
plugin on Linux. This preserves a common Dockerfile/Compose workflow. Desktop's
[licensing terms](https://docs.docker.com/subscription-billing/desktop-license/)
depend on how it is used, including organization size.

On a new macOS machine, bootstrap includes Docker Desktop. For a targeted install,
run `brew bundle --file=Brewfile.containers`, then open Docker Desktop and complete
first launch. Homebrew's CLI links and post-install Kubernetes link can require
an administrator password, so run this command in an interactive terminal.

On the current Mac, Docker Desktop was first installed on 2026-10-04 by copying
the application from the Homebrew-fetched Docker DMG into `/Applications`. The
separate [Docker inventory](../inventory/docker-desktop.txt) records that
installation and its later adoption by Homebrew. For manual installation on
another Mac, mount the official Apple Silicon DMG, copy `Docker.app` into
Applications, launch it, and complete first launch.

### Adopting a manually installed app

A copied app has no Homebrew cask receipt, so `brew bundle check` reports
`Cask docker-desktop needs to be installed or updated.`, and bootstrap is
expected to stop at the bundle step. Do not delete or uninstall Docker Desktop to fix this. Bring
the existing app under Homebrew instead:

1. In System Settings → Privacy & Security → App Management, allow your
   terminal app, then quit and reopen it. Without this, macOS blocks even
   `sudo chmod` inside `Docker.app` with `Operation not permitted`.
2. In that terminal window, run `brew install --cask --adopt docker-desktop`
   and enter your password. A non-interactive shell, such as Claude Code's `!`
   prefix, cannot show the password prompt and fails.

Adoption keeps the existing app and data. On 2026-10-18 an attempt with a
4.93.0 app against the 4.95.0 cask passed the version check (the cask is
`auto_updates`) and stopped only at the `sudo` prompt. The 2026-10-21 adoption
that succeeded had matching versions. If adoption cannot work,
`brew install --cask --force docker-desktop` quits Docker, replaces the app and
reinstalls its helpers; images, containers and volumes stay in
`~/Library/Containers/com.docker.docker`.
Never use Docker Desktop's Troubleshoot → Uninstall or `brew uninstall --zap`
for this, because both delete that data.

Until a Mac is adopted, skip the cask when running bundle commands:

```sh
HOMEBREW_BUNDLE_CASK_SKIP=docker-desktop brew bundle check --verbose --file=Brewfile
HOMEBREW_BUNDLE_CASK_SKIP=docker-desktop bash scripts/bootstrap.sh
```

The current Mac was adopted on 2026-10-21 and no longer needs the skip
variable. Macs that install Docker through bootstrap or `Brewfile.containers`
get a normal receipt and are not affected.

### Docker CLI paths

Docker Desktop can install CLI tools in the user directory `~/.docker/bin`;
the shell supports this directory and the bundled CLI. The Homebrew cask also
creates root-owned links in `/usr/local/bin` (`docker`, credential helpers) and
`/usr/local/cli-plugins/docker-compose`. Docker Desktop may append a block to
`~/.zprofile` that adds `~/.docker/bin` to `PATH`. That block is redundant with
the tracked zshrc; `scripts/install-shell.sh` replaces `~/.zprofile` without
it, and Docker may add it again later.

### Other platforms

Windows: follow the [official Desktop installer](https://docs.docker.com/desktop/setup/install/windows-install/)
and enable WSL integration for your Ubuntu distribution. Do not also install a
second engine inside WSL. Linux: follow [Engine installation](https://docs.docker.com/engine/install/)
for your distribution. Docker socket access can provide root-equivalent access;
choose the documented rootless setup when appropriate.

### Verify and use

Verify `docker version`, `docker compose version`, and `docker run --rm hello-world`.
Keep project services in a Compose file with explicit image versions, health checks,
and named volumes. Docker Desktop is part of the desired macOS `Brewfile`; `Brewfile.containers`
provides a targeted install.
