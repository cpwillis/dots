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
- Unless `~/.ssh/id_ed25519` exists, `gh auth login` (browser) generates an SSH key and adds it to your GitHub account
- `chsh -s /bin/zsh`
- Offers `sudo softwareupdate -ia --restart` at the end

Test it on CI first, see [Test on CI](#test-on-ci).

## Run

```sh
./scripts/install.sh --dry-run            # print commands, change nothing
./scripts/install.sh                      # run every step not yet done
./scripts/install.sh --skip ssh           # leave steps for later, a plain rerun picks them up
./scripts/install.sh --only ssh,dotfiles  # run just these, even if already done
./scripts/install.sh --fresh              # forget progress and run every step again
```

Steps, in order: `homebrew packages omz macos dotfiles ssh shell update`. Each finished step is recorded in
`~/.local/state/dots/install-done`, so a run that fails or is stopped with Ctrl+C resumes at the step it stopped on.
`--dry-run` reads that file but never writes it.

Every run prompts for confirmation. The `packages` step opens the App Store and blocks until you confirm you are
signed in, since the Brewfile has `mas` entries, even under `--dry-run`. If `brew bundle` can't install an item (eg a
cask Homebrew has since disabled), the install skips it, carries on, and lists it at the end; fix it and rerun with
`--only packages`.

From a Mac with nothing checked out (installs the Xcode Command Line Tools if missing, clones to `~/Downloads/dots`,
deleting any existing copy, then runs the installer):

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/cpwillis/dots/main/scripts/repo_download.sh)"
```

## Test on CI

`.github/workflows/install-test.yml` ("Fresh macOS Install" in the Actions tab) runs `install.sh` end to end on a
GitHub macOS runner. It only runs when dispatched by hand, one run at a time:

```sh
gh workflow run install-test.yml
gh run watch
```

First it makes the runner look like a fresh Mac: it deletes the runner's Homebrew and its preinstalled Chrome,
Firefox and VS Code, and points `xcode-select` at the Command Line Tools. It skips App Store apps via
`HOMEBREW_BUNDLE_MAS_SKIP` (no Apple ID) and pre-creates `~/.ssh/id_ed25519` so the `gh` login is skipped. After the
install it checks that a rerun has nothing to do and that a new login shell, with a clean environment as Terminal
opens it, starts without errors.

Not covered: `repo_download.sh` and the Command Line Tools install (the runner already has them), App Store apps, and
the `gh` SSH key login.

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

`config/gnupg/gpg-agent.conf` is deployed, but GPG keys and `~/.aws` are not in this repo. Restore those by hand.

## Manual, after install

Set `email` and `signingkey` in `~/.gitconfig`. It deploys with placeholders and `gpgSign = true`, so commits fail
until both are set.

Restore from backups in `~/Documents/Misc`:

- iTerm2: Preferences → General → Settings → Import All Settings and Data
- Alfred: Advanced → Set preferences folder

Install by hand: [KiCad](https://www.kicad.org/download/macos/), [CleanMyMac](https://my.macpaw.com/),
[PrusaSlicer](https://www.prusa3d.com/page/prusaslicer_424/).

Re-enter licenses: Alfred, Shottr, BetterDisplay, Bruno, CleanMyMac, TablePlus.
