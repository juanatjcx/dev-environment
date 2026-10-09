# Container workflow

Use Docker Desktop on macOS and Windows; use native Docker Engine with the Compose
plugin on Linux. This preserves a common Dockerfile/Compose workflow. Desktop's
[licensing terms](https://docs.docker.com/subscription-billing/desktop-license/)
depend on how it is used, including organization size.

On a new macOS machine, bootstrap includes Docker Desktop. For a targeted install,
run `brew bundle --file=Brewfile.containers`, then open Docker Desktop and complete
first launch. Homebrew's CLI links and post-install Kubernetes link can require
an administrator password, so run this command in an interactive terminal.

On the current Mac, Docker Desktop was installed successfully on 2026-10-04 by
copying the application from the Homebrew-fetched Docker DMG into `/Applications`.
The app is running and all checks below passed. It has no Homebrew cask receipt;
Homebrew may report it missing or refuse to overwrite the existing app. Do not
reinstall it merely to satisfy a package check. The separate
[Docker inventory](../inventory/docker-desktop.txt) records this installation.
For manual installation on another Mac, mount the official Apple Silicon DMG,
copy `Docker.app` into Applications, launch it, and complete first launch.

Docker Desktop can also install CLI tools in the user directory `~/.docker/bin`;
the shell supports this directory and the bundled CLI. Windows: follow the [official Desktop installer](https://docs.docker.com/desktop/setup/install/windows-install/)
and enable WSL integration for your Ubuntu distribution. Do not also install a
second engine inside WSL. Linux: follow [Engine installation](https://docs.docker.com/engine/install/)
for your distribution. Docker socket access can provide root-equivalent access;
choose the documented rootless setup when appropriate.

Verify `docker version`, `docker compose version`, and `docker run --rm hello-world`.
Keep project services in a Compose file with explicit image versions, health checks,
and named volumes. Docker Desktop is part of the desired macOS `Brewfile`; `Brewfile.containers`
provides a targeted install.
