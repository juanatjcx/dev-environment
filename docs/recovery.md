# Recovery and Apple development

Checked on 2026-10-02: FileVault is enabled; automatic update checking, downloads,
and critical update installation are enabled. Time Machine has no destination.
To finish backups, connect a backup disk or choose a network destination in
System Settings → General → Time Machine. Enable encryption for the backup.
The destination and its password require your input. Keep account recovery codes
in your password manager, not this repository.

## Xcode

Xcode 27.0 (27A266a) is installed and selected at
`/Applications/Xcode.app/Contents/Developer`; `xcodebuild -version` verified this
after the user completed setup on 2026-10-02. For a new Apple development machine:

1. Open Xcode and complete first-launch components and license prompts.
2. In Xcode → Settings → Locations, select Xcode for Command Line Tools; or run
   `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`.
3. In Settings → Accounts, add your Apple development account
   and complete sign-in/2FA. Select the appropriate team for signing in the project.
   The email alone cannot supply credentials or team membership.
4. Install only the platforms/simulators your project targets through Xcode's
   component settings. Confirm `xcodebuild -version` and build an actual project.

Steps requiring license acceptance, Apple sign-in, or choosing a backup destination
are intentionally interactive. No passwords or recovery keys are captured here.
