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
The app is running and all checks below passed. The separate
[Docker inventory](../inventory/docker-desktop.txt) records this installation.
For manual installation on another Mac, mount the official Apple Silicon DMG,
copy `Docker.app` into Applications, launch it, and complete first launch.

### Known issue: no Homebrew cask receipt

Because the app was copied rather than installed by `brew install --cask`,
Homebrew has no record of it. This is expected on this Mac. It is not a broken
installation. It has two effects:

- `brew bundle check --file=Brewfile` fails with
  `Cask docker-desktop needs to be installed or updated.`
- `bash scripts/bootstrap.sh` tries to install the cask. Homebrew is expected to refuse
  to overwrite the existing `/Applications/Docker.app`, and because bootstrap uses
  `set -e`, it would stop before the shell setup steps.

Do not delete or reinstall Docker Desktop just to satisfy these checks. On this
Mac, skip the cask when running bundle commands:

```sh
HOMEBREW_BUNDLE_CASK_SKIP=docker-desktop brew bundle check --verbose --file=Brewfile
HOMEBREW_BUNDLE_CASK_SKIP=docker-desktop bash scripts/bootstrap.sh
```

To bring the app under Homebrew later, run
`brew install --cask --adopt docker-desktop` in an interactive terminal. Adoption
only works when the installed app is identical to the cask's current version.
The 2026-10-04 install is 4.93.0, and the cask had moved to 4.94.0 by
2026-10-09, so adoption is expected to fail until the versions match. If it
works, `brew bundle check` stops reporting Docker, and you can drop the skip
variable. Docker Desktop updates itself either way. Macs that install Docker
through bootstrap or `Brewfile.containers` get a normal receipt and are not
affected. A manual DMG install, as described above, has the same issue.

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
