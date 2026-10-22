# Developer workflow

This setup provides source navigation, project Node pins, Vim language
tooling, explicit Python tooling, and Docker Desktop on macOS.

- **Node:** use `.nvmrc` in each Node project. Shell directory changes select
  installed pins; missing versions print an instruction to run `nvm install`.
  Outside pinned projects the shell returns to the nvm default. Existing CI
  majors are preserved: jcxsoftware uses 22, Calor's website uses 20.
  Review older majors separately rather than mixing upgrades into setup work.
  Keep dependency lockfiles and use `npm ci`.
- **.NET:** Calor pins SDK 10.0.100 with `latestMinor` roll-forward, so newer
  10.0 SDKs from Homebrew work. Preserve that existing policy. When Homebrew's
  `dotnet` moves to a new major, Calor will no longer find a matching SDK; plan
  that bump in Calor or install a 10.0 SDK in the same dotnet root.
- **Editor:** see [Vim tooling](editor.md). EditorConfig files are added to
  this repo and the two Node projects; existing source is not reformatted.
- **Python:** see [uv workflow](python.md). Keep environments inside projects;
  do not install application dependencies into Homebrew's Python.
- **Containers:** Docker Desktop is installed on this Mac. Keep services and
  container configuration scoped to the projects that require them; see
  [container workflow](containers.md).
- **Apple development:** full Xcode is selected on this Mac. Install the SDKs
  and simulators required by the particular project.
- **Git:** keep directory-scoped personal/work identities and
  `user.useConfigOnly=true`; confirm the identity before a first commit.

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
selected Xcode, the Docker engine when a project has a Dockerfile or Compose
file, and whether the Claude Code plugin list is installed. Project command
wrappers are not implemented.
