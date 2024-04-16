# new-mac

This script is tailored to swiftly set up my essential tools and applications on macOS.

### Quick Install

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/cpwillis/new-mac/main/install.sh)"
```

<details>
  <summary>Post-Installation</summary>

- iStat Menus, Import Preferences `(~/Documents/Misc)`
- Alfred, Set Preferences Folder `(~/Documents/Misc)`
- Insta360 Link Controller, [Download](https://www.insta360.com/download/insta360-link)
</details>

### About

<details>
  <summary>Homebrew and Brewfile</summary>

Homebrew is an unofficial package manager for macOS, simplifying the installation, updating, and management of user applications. Utilizing Git and Ruby, it installs packages within its prefix and symlinks them to the appropriate locations on disk, providing flexibility for customization and easy rollback of changes. Accessed via the terminal with the `brew` command, Homebrew also offers an unofficial GUI called Cakebrew. The Brewfile defines a list of packages to install on your system, featuring keywords like `brew`, `cask`, `tap`, and `mas`, each serving specific purposes as detailed in the documentation's terminology section. Lines starting with brew install pre-compiled binary packages, casks install GUI applications, taps add extra repositories, and mas enables installation of apps from the Apple App Store directly within your Brewfile.

</details>

<details>
  <summary>Dotfiles</summary>

Dotfiles, customizable configuration files typically stored in the user's home directory or `~/.config`, are named with a dot prefix (e.g., `.gitconfig`, `.zshrc`, `.vimrc`). Managed via Git, they enable effortless backups, rollbacks, and synchronization across environments, ensuring a consistent setup on multiple machines and expediting the process of setting up a new system.

Prioritizing security when managing dotfiles is paramount due to the potential inclusion of sensitive information like SSH keys or passwords. Solutions encompass utilizing `.gitignore` to prevent committing private files and ensuring setups aren't reliant on them. Encryption options such as `pass` or plain GPG bolster security. Additionally, tools like Git-crypt provide GPG-based encryption tailored for Git repositories, furnishing plaintext fallback versions to prevent errors if GPG keys are absent.

</details>

### Misc

<details>
  <summary>Brewfile Management Commands</summary>

- Install from Brewfile at current path: `$ brew bundle`
- Install from specific Brewfile: `$ brew bundle --file=[path/to/file]`
- Create Brewfile from installed packages: `$ brew bundle dump`
- Uninstall formulae not in Brewfile: `$ brew bundle cleanup --force`
- Check for install or upgrade in Brewfile: `$ brew bundle check`
- Output all Brewfile entries: `$ brew bundle list --all`
</details>

<details>
  <summary>Test Script in VM</summary>

It's advisable to test your script on a fresh Mac VM to ensure proper functionality. Installing on a clean Mac install allows you to identify potential issues that may not surface when repeatedly running the script on your own computer.

- **Intel**: Install Intel Mac OS VMs using [Virtualbox](https://github.com/myspaghetti/macos-virtualbox).
- **Apple Silicon (M1/M2)**: Utilize [VirtualBuddy](https://github.com/insidegui/VirtualBuddy) to run Mac OS VMs using Apple's Virtualization framework.

</details>
