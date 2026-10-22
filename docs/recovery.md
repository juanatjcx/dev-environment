# Recovery and Apple development

On each Mac, confirm that FileVault is enabled and that automatic update
checking, downloads, and critical update installation are enabled. Set up
backups by connecting a backup disk or choosing a network destination in
System Settings → General → Time Machine. Enable encryption for the backup.
The destination and its password require your input. Keep account recovery codes
in your password manager, not this repository.

## Xcode

Select full Xcode at `/Applications/Xcode.app/Contents/Developer` rather than
the Command Line Tools. For a new Apple development machine:

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
