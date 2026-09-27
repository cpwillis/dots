# dots

Personal macOS dotfiles plus a one-shot setup script for a fresh Mac. Opinionated and single-user, not built to be
configurable.

## What install.sh does to a machine

Irreversible. Read `scripts/install.sh` before running it.

- `sudo rm -rf` on `/Applications/{GarageBand,Pages,Numbers,Keynote}.app`
- Copies every file in `meta/manifest.csv` over its system path, no backup of what was there
- Runs every `defaults write` line in `meta/macOS_settings.sh`, then `killall Dock Finder SystemUIServer`
- Installs Homebrew (which brings the Xcode Command Line Tools), Oh My Zsh and the `omz-git-branch` plugin
- `brew update && brew upgrade` (upgrades packages you already had), installs `config/Brewfile`, then `brew cleanup`
- `chsh -s /bin/zsh`
- Offers `sudo softwareupdate -ia --restart` at the end

Test in a VM first: [VirtualBuddy](https://github.com/insidegui/VirtualBuddy) on Apple Silicon,
[macos-virtualbox](https://github.com/myspaghetti/macos-virtualbox) on Intel.

## Run

```sh
./scripts/install.sh --dry-run   # print commands, change nothing
./scripts/install.sh
```

Both prompt for confirmation, then open the App Store and block until you confirm you are signed in, since the
Brewfile has `mas` entries. `--dry-run` still prompts and still opens the App Store.

From a Mac with nothing checked out (installs the Xcode Command Line Tools if missing, clones to `~/Downloads/dots`,
deleting any existing copy, then runs the installer):

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/cpwillis/dots/main/scripts/repo_download.sh)"
```

## Sync back

`scripts/update_configs.sh` pulls live config into the repo, overwriting:

- every `repo_path` in `meta/manifest.csv`, from its system path
- `config/Brewfile`, via `brew bundle dump --force`; if the dump has no `mas` lines it reinstalls `mas` and retries,
  up to 3 attempts

It then rewrites `email` and `signingkey` in `config/.gitconfig` to placeholders, so real values never reach the repo.
`--commit` refuses to commit if any file under `config/` or `meta/` contains your `$HOME` path.

```sh
./scripts/update_configs.sh            # sync only
./scripts/update_configs.sh --commit   # sync, then git add . && git commit && git push
```

`scripts/generate_macOS_settings.sh` regenerates `meta/macOS_settings.sh` from the current system, overwriting it.
Run it yourself, `update_configs.sh` does not call it. Keys missing from the defaults database are skipped silently,
which is why some comments in that file have no command under them.

## Adding a dotfile

Add a row to `meta/manifest.csv`: `name, repo_path, system_path`. Install and sync both read it, so one row covers
deploy and sync back. `system_path` is `eval`'d, so `$HOME` expands.

## Not installed for you

`config/git-hooks/pre-push` blocks direct pushes to `main` (bypass with `ALLOW_MAIN_PUSH=true`). Nothing deploys it.
Copy it into a repo's `.git/hooks/` and `chmod +x` it.

`config/gnupg/gpg-agent.conf` is deployed, but GPG keys, SSH keys and `~/.aws` are not in this repo. Restore those
by hand.

## Manual, after install

Set `email` and `signingkey` in `~/.gitconfig`. It deploys with placeholders and `gpgSign = true`, so commits fail
until both are set.

Restore from backups in `~/Documents/Misc`:

- iTerm2: Preferences → General → Settings → Import All Settings and Data
- Alfred: Advanced → Set preferences folder

Install by hand: [KiCad](https://www.kicad.org/download/macos/), [CleanMyMac](https://my.macpaw.com/),
[PrusaSlicer](https://www.prusa3d.com/page/prusaslicer_424/).

Re-enter licenses: Alfred, Shottr, BetterDisplay, Bruno, CleanMyMac, TablePlus.
