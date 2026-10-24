# Developer workflow

This setup provides source navigation, project Node pins, Vim language
tooling, explicit Python tooling, and Docker Desktop on macOS.

- **Node:** use `.nvmrc` in each Node project. Shell directory changes select
  installed pins; missing versions print an instruction to run `nvm install`.
  Outside pinned projects the shell returns to the nvm default. Keep each
  project's pin in step with its CI, and review older majors separately rather
  than mixing upgrades into setup work.
  Keep dependency lockfiles and use `npm ci`.
- **.NET:** Calor's `global.json` uses `latestMinor` roll-forward, so newer
  SDKs of the same major from Homebrew work. Preserve that policy. When
  Homebrew's `dotnet` moves to a new major, Calor no longer finds a matching
  SDK; plan that bump in Calor or install the older SDK in the same dotnet
  root.
- **Editor:** see [Vim tooling](editor.md). EditorConfig files are added to
  this repo and the two Node projects; existing source is not reformatted.
- **Python:** see [uv workflow](python.md). Keep environments inside projects;
  do not install application dependencies into Homebrew's Python.
- **Containers:** Docker Desktop is installed on macOS. Keep services and
  container configuration scoped to the projects that require them; see
  [container workflow](containers.md).
- **Apple development:** select full Xcode rather than the Command Line Tools.
  Install the SDKs and simulators required by the particular project.
- **Git:** keep directory-scoped personal/work identities and
  `user.useConfigOnly=true`; confirm the identity before a first commit. Sign
  commits with 1Password; see [accounts](accounts.md#signing-commits-with-1password).

## Suggested project commands

Keep the existing ecosystem commands and document them in each project's
README: setup, development, validation, and formatting. Avoid adding a wrapper
unless it removes real repetition. Examples from the current repositories:

| Project | Setup | Development | Validation |
| --- | --- | --- | --- |
| jcxsoftware | `nvm install && npm ci` | `npm run dev` | `npm run check && npm run build` |
| jcxsoftware/api | `nvm install && npm ci` | Project-specific Azure Functions host | `npm test` |
| Calor website | `nvm install && npm ci` | `npm run dev` | `npm run build`, selected Playwright tests |
| Calor compiler | Download Z3 assets per AGENTS.md, `dotnet restore` | Existing CLI/build workflow | Scoped `dotnet test tests/<Project>/` |

`scripts/doctor.sh` reports these: each project's `.nvmrc` pin against the Node
versions nvm has installed, the .NET SDK each `global.json` resolves to, the
selected Xcode, Touch ID for sudo, the Docker engine when a project has a
Dockerfile or Compose file, and whether the Claude Code plugins on the list are
installed and enabled. Project command wrappers are not implemented.
