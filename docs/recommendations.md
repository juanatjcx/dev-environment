# Recommended next steps

These are opt-in follow-ups, not software silently installed by the shell setup.

1. **Choose project runtimes explicitly.** The captured Mac has Node 26.10.0 and
   .NET SDK 10.0.401. Keep Homebrew Node for the captured global CLI tools; use
   `nvm install --lts` for new projects, then `nvm use`, and commit an `.nvmrc`
   with the chosen exact version. Existing projects may require other versions.
   Commit package-manager lockfiles and use `npm ci`. For .NET, commit
   [`global.json`](https://learn.microsoft.com/en-us/dotnet/core/tools/global-json)
   with the intended SDK/roll-forward policy. Install missing SDKs explicitly.
   The Homebrew nvm loader fixes the current missing initialization; upstream
   [nvm does not support Homebrew installation](https://github.com/nvm-sh/nvm).
   Consider migrating to upstream nvm if troubleshooting is needed. Do not remove
   Homebrew Node blindly: global Homebrew tools can depend on it.
2. **Add source navigation tools.** Run `brew bundle --file=Brewfile.optional`
   for ripgrep, jq, and fzf. This is a small optional toolkit, not an expansion
   of every shell plugin. Enable fzf's shell integration only if you want its
   key bindings to replace the existing history search.
3. **Use Vim.** The shell defaults to Vim and installs `shell/vimrc` with search,
   completion, syntax highlighting, and filetype indentation. No external plugins
   are required. The desired Brewfile includes current Vim; macOS's built-in Vim
   works immediately. Keep language formatters and lint rules in each project.
4. **Separate work and personal Git identities.** Use owner-directory-scoped
   `includeIf` files, verified emails, and approved organization credentials.
   Confirm with `git var GIT_AUTHOR_IDENT` inside each repository. Keep 1Password
   for secrets; configure SSH signing/agent integration only if your workflow or
   organization requires it.
5. **Use Docker when a project needs containers.** See [the platform-specific container setup](containers.md). For repositories with databases or
   platform-specific dependencies, consider a dev container and Compose services.
   Install a container engine only when a project needs it; document its version
   and startup requirements in that project. Do not install every language manager
   preemptively. Python projects should use an explicit runtime and virtualenv;
   the current Homebrew Python is a transitive dependency, not a tracked choice.
6. **Check native Apple development separately.** Xcode.app exists, but the
   active developer directory is `/Library/Developer/CommandLineTools`. This is
   sufficient for many CLI builds. For Apple app work, select Xcode in its Settings
   or deliberately use `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`,
   complete first-launch setup, and install the project-required SDK/simulators.
7. **Maintain recovery basics.** FileVault and automatic updates were verified enabled on this Mac; Time Machine needs a destination. See [the recovery checklist](recovery.md). Enable OS updates, disk encryption, and encrypted
   backups. Push this repo to its remote and maintain a private account recovery
   checklist. Never store recovery codes, API keys, SSH private keys, or shell
   history in it.

After setup, confirm `git --version`, `node --version`, `nvm --version`,
`dotnet --list-sdks`, `gh auth status`, and the build/test commands of an actual
project. Packages alone do not prove a project works.
