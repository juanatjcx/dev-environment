# Personal and work GitHub accounts

Run `bash scripts/setup-git.sh PERSONAL_EMAIL WORK_EMAIL` with verified commit
emails. Email addresses are written to local Git configuration, not this repo.
An empty work email deliberately blocks work commits until supplied.

Repos under `~/repos/juanatjcx/` use the personal identity; repos under
`~/repos/juanmicrosoft/` use the work identity. Both use the author name Juan Rivera.
Verify inside each clone with `git var GIT_AUTHOR_IDENT` and
`git config --get dev.githubAccount`. Local repo configuration takes precedence;
check `git config --show-origin --get user.email` if it differs.

Commit attribution and authentication are separate. Sign in to both accounts
using `gh auth login --hostname github.com --git-protocol https` (choose the
intended account in the browser each time). After both logins, Git HTTPS operations automatically retrieve the credential for
the directory's account using the installed helper. Interactive zsh `gh` commands
likewise select that account via a per-command environment token without changing
the global active account. `gh auth ...` passes through for account management.
Explicit `GH_TOKEN`, `GITHUB_TOKEN`, or `GH_HOST` overrides also pass through.

Outside these directories, the normal active account applies. Noninteractive
scripts and other shells calling `gh` do not load the zsh wrapper: select an account
explicitly for those. If you target a different repository using `gh -R`, the
current directory still determines the account; run it from the intended clone.
No account is inferred from a repository's owner alone.

Git credentials are fetched from GitHub CLI's local credential storage and are
never saved in this repository. Missing account credentials fail rather than
silently falling back to another account. Work-account sign-in remains necessary.

See [Git conditional configuration](https://git-scm.com/docs/git-config) and
[GitHub multiple-account guidance](https://docs.github.com/en/account-and-profile/how-tos/account-management/managing-multiple-accounts).

## Google Cloud and Firebase accounts

gcloud does not switch accounts by directory. To keep personal and work
accounts apart, give each its own named configuration and switch deliberately.
This machine currently has only the `default` configuration, signed in with the
personal account. To add a work configuration:

```sh
gcloud config configurations create work   # creates and activates it
gcloud auth login                          # choose the work account
gcloud config configurations activate default
```

Check which account is active with `gcloud config configurations list`.
To use a configuration for one command, add `--configuration=work`; to use it
for one shell, run `export CLOUDSDK_ACTIVE_CONFIG_NAME=work`.

Application Default Credentials (`gcloud auth application-default login`), which
client libraries and local emulators use, are stored in one file per machine.
Switching configurations does not change them; run that login again after switching.

The Firebase CLI keeps its own sign-ins. Add a second account with
`firebase login:add`, then run `firebase login:use <email>` inside a project
directory to select that account for that project. Outside a Firebase project
directory, the same command changes the global default account instead.

Credentials stay in `~/.config/gcloud` and the Firebase CLI's own config. Never
commit or copy them into this repo.
