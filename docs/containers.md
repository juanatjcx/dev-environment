# Container workflow

Use Docker Desktop on macOS and Windows; use native Docker Engine with the Compose
plugin on Linux. This preserves a common Dockerfile/Compose workflow. Desktop's
[licensing terms](https://docs.docker.com/subscription-billing/desktop-license/)
depend on how it is used, including organization size.

macOS: `brew bundle --file=Brewfile.containers`, then open Docker Desktop and
complete its first launch. Run the Homebrew command in an interactive terminal:
the cask's binary links and post-install Kubernetes link can require an administrator
password, even with `--no-binaries`. On the captured Mac, automated installation
was rolled back because it could not prompt for that password. To finish, run
`brew install --cask docker-desktop` locally, then open Docker Desktop.
Docker Desktop can also install CLI tools in the user directory `~/.docker/bin`;
the shell supports this directory and the bundled CLI. Windows: follow the [official Desktop installer](https://docs.docker.com/desktop/setup/install/windows-install/)
and enable WSL integration for your Ubuntu distribution. Do not also install a
second engine inside WSL. Linux: follow [Engine installation](https://docs.docker.com/engine/install/)
for your distribution. Docker socket access can provide root-equivalent access;
choose the documented rootless setup when appropriate.

Verify `docker version`, `docker compose version`, and `docker run --rm hello-world`.
Keep project services in a Compose file with explicit image versions, health checks,
and named volumes. Docker Desktop is included in the desired macOS baseline.
