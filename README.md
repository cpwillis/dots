# dots

Personal macOS dotfiles - automated setup for a fresh Mac install.

## Quick Start

### Sync Configs

```sh
./scripts/update_configs.sh # sync only
```

```sh
./scripts/update_configs.sh --commit # sync, commit, and push
```

### Download and Install

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/cpwillis/dots/main/scripts/repo_download.sh)"
```

## What's Included

| Category           | Examples                                          |
| ------------------ | ------------------------------------------------- |
| CLI tools          | git, pyenv, atuin, gh, direnv, awscli, bat, delta |
| Apps (Cask)        | VSCode, iTerm2, Alfred, Obsidian, Bruno           |
| App Store          | Xcode, Affinity suite, Office suite, Magnet       |
| VS Code extensions | GitLens, Ruff, Claude Code, Pylance, GitGraph     |

**Dotfiles:** `.zshrc`, `.gitconfig`, VSCode settings & snippets, GPG agent config.

## Scripts

| Script                                                                     | Purpose                                                                               |
| -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| [`scripts/install.sh`](scripts/install.sh)                                 | Full system setup (run once on a fresh Mac)                                           |
| [`scripts/update_configs.sh`](scripts/update_configs.sh)                   | Sync current system configs back to repo                                              |
| [`scripts/repo_download.sh`](scripts/repo_download.sh)                     | Clone the repo and run the installer                                                  |
| [`scripts/generate_macOS_settings.sh`](scripts/generate_macOS_settings.sh) | Capture current macOS preferences - run separately, not called by `update_configs.sh` |

`install.sh` reads [`meta/manifest.csv`](meta/manifest.csv) to deploy all dotfiles - add a row there to include a new file in both install and sync.

## Post-Installation (Manual)

Settings backups are stored in `~/Documents/Misc`:

- **iTerm2:** Preferences → General → Settings → _Import All Settings and Data..._
- **Alfred:** Advanced → _Set preferences folder..._

Manual installs:

- [KiCad EDA](https://www.kicad.org/download/macos/)
- [CleanMyMac X](https://my.macpaw.com/)
- [PrusaSlicer](https://www.prusa3d.com/page/prusaslicer_424/)

Licenses: Alfred, Shottr, BetterDisplay, Bruno, CleanMyMac X

Private dotfiles (`.aws/`, `.gnupg/`) are excluded from the repo - restore manually.

## Reference

<details>
<summary>Brewfile commands</summary>

| Command                       | Description                                |
| ----------------------------- | ------------------------------------------ |
| `brew bundle`                 | Install from Brewfile in current directory |
| `brew bundle --file=path`     | Install from a specific Brewfile           |
| `brew bundle dump`            | Create Brewfile from installed packages    |
| `brew bundle cleanup --force` | Remove packages not listed in Brewfile     |
| `brew bundle check`           | Check all Brewfile entries are installed   |
| `brew bundle list --all`      | Print all entries in the Brewfile          |

</details>

<details>
<summary>Testing in a VM</summary>

Test on a clean Mac before running on your own machine:

- **Intel:** [macos-virtualbox](https://github.com/myspaghetti/macos-virtualbox)
- **Apple Silicon:** [VirtualBuddy](https://github.com/insidegui/VirtualBuddy)

</details>

<details>
<summary>GitHub Codespaces</summary>

Settings → Codespaces → Dotfiles → _Automatically install dotfiles_

- [How to set up dotfiles for Codespaces](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles)
- [dotfiles.github.io](https://dotfiles.github.io/)

</details>
