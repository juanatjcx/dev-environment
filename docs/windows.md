# Windows

Use WSL2 for the same zsh/toolchain workflow as macOS and Linux. In an administrator
PowerShell terminal, run:

```powershell
wsl --install -d Ubuntu
```

Restart if requested, open Ubuntu, and create a Linux user. Follow the Linux steps
in [README](../README.md) inside Ubuntu. See Microsoft's [WSL installation guide](https://learn.microsoft.com/en-us/windows/wsl/install).

Keep Linux projects in `~/repos/<owner>/<repo>` inside WSL. Microsoft recommends
the [Linux filesystem for Linux tools](https://learn.microsoft.com/en-us/windows/wsl/filesystems)
for performance. Access it from Explorer using `\\wsl$`; avoid building Linux
projects under `/mnt/c/Users/...`.

Use Windows Terminal with an Ubuntu profile. Install your chosen editor on Windows
and its WSL integration, then open projects in WSL. Install Windows desktop apps
(e.g. 1Password) separately from their official installers. macOS casks are skipped
inside WSL. Secrets, Git identities, and cloud authentication need separate setup
inside WSL; Windows credentials are not assumed to transfer.

## Native Windows projects

For Windows-specific .NET or desktop work, install native Git, the .NET SDK required
by the project's `global.json`, and an appropriate IDE from their official installers.
Install native Node only if that project needs it, matching the project's version.
Use `$HOME\repos\<owner>\<repo>` for native projects. Keep native and WSL clones
separate so dependency directories and build outputs do not mix platforms.

Oh My Zsh configuration applies to WSL, not PowerShell. This repo automates the
WSL workflow; native Windows tool installation and PowerShell customization are
manual. A native Windows manifest should be added if native development becomes
the preferred workflow.
