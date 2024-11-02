#!/bin/sh


# SCRIPT OVERRIDES -----------------------------------------------------------------------------------------------------
# accept args if install.sh is run directly to only run certain steps


# COLOUR_ECHO ----------------------------------------------------------------------------------------------------------
black=$(tput setaf 0) red=$(tput setaf 1) green=$(tput setaf 2) yellow=$(tput setaf 3) blue=$(tput setaf 4) magenta=$(tput setaf 5) cyan=$(tput setaf 6) white=$(tput setaf 7) reset=$(tput sgr0)
cecho() { echo "${2}${1}${reset}"; } # $1=msg $2=col


# WARNINGS -------------------------------------------------------------------------------------------------------------
echo "" # Font: ANSI Shadow (https://www.asciiart.eu/text-to-ascii-art)
echo " ██████╗██████╗ ██╗    ██╗██╗██╗     ██╗     ██╗███████╗"
echo "██╔════╝██╔══██╗██║    ██║██║██║     ██║     ██║██╔════╝"
echo "██║     ██████╔╝██║ █╗ ██║██║██║     ██║     ██║███████╗"
echo "██║     ██╔═══╝ ██║███╗██║██║██║     ██║     ██║╚════██║"
echo "╚██████╗██║     ╚███╔███╔╝██║███████╗███████╗██║███████║"
echo " ╚═════╝╚═╝      ╚══╝╚══╝ ╚═╝╚══════╝╚══════╝╚═╝╚══════╝"
echo "--------------------------------------------------------"
echo "          Q U I C K   S E T U P   S C R I P T           "

cecho "
*********************************************************
*  WARNING: Review script thoroughly before running.    *
*  Unforeseen changes may occur. Use at your own risk.  *
*********************************************************
" $red # Font: Term

if ! read -rp "$(cecho 'Have you reviewed the script and understood its impact? (y/n) ' "$yellow")" response || [[ ! $response =~ ^[yY]$ ]]; then
    cecho "Please review and make changes before continuing. It only takes a few minutes." "$red"
    exit
fi


# ADMIN (ask for pwd then keep-alive) ----------------------------------------------------------------------------------
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


# INSTALL BREW (Prerequisite) ------------------------------------------------------------------------------------------
echo "Installing brew..." # https://brew.sh/
if ! command -v brew >/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null
fi
brew upgrade
brew update


# XCODE ----------------------------------------------------------------------------------------------------------------
if ! command -v xcode-select >/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
else
    echo "Xcode Command Line Tools are already installed."
fi


# BUNDLE: TAP/BREW/CASK/MAS/VSCODE -------------------------------------------------------------------------------------
echo "Starting app install..."
while true; do
    open -a "App Store"
    if ! read -rp "$(cecho 'Please login to the App Store to continue. Is this complete? (y/n) ' "$yellow")" response || [[ ! $response =~ ^[yY]$ ]]; then
        cecho "Please try again or exit the script (ctrl+c)." "$red"
    else
        break
    fi
done
brew bundle --file=[config/Brewfile] # https://github.com/Homebrew/homebrew-bundle
brew cleanup


# Oh My Zsh ------------------------------------------------------------------------------------------------------------
echo "Installing Oh My Zsh..." # https://ohmyz.sh/
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


# macOS (https://github.com/mathiasbynens/dotfiles/blob/master/.macos) --------------------------------------------------
# close settings pane to prevent accidental overrides
osascript -e 'tell application "System Preferences" to quit'

# apply settings
macOS_settings="config/macOS_settings.txt"
if [ -f "$macOS_settings" ]; then
    echo "Running commands from $macOS_settings..."
    while IFS= read -r line; do
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue # skip comments and empty lines
        echo "Executing: $line"
        eval "$line" # execute the command
    done < "$macOS_settings"
else
    echo "Settings file $macOS_settings not found."
fi

# unwanted stock apple apps
for app in "GarageBand" "Pages" "Numbers" "Keynote"; do
    app_path="/Applications/${app}.app"
    [ -d "$app_path" ] && echo "Removing $app..." && sudo rm -rf "$app_path" || echo "$app not found."
done


# GitHub (SSH Keys) ----------------------------------------------------------------------------------------------------
# generate ssh keys & add to ssh-agent, add ssh-key to GitHub via api


# DOTFILES -------------------------------------------------------------------------------------------------------------
# https://github.com/Lissy93/dotfiles#directory-structure
# use locations.txt here (and use it in update_configs.sh)
echo "Copying .zshrc to the home directory..."
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cp -i "$SCRIPT_DIR/.zshrc" ~/.zshrc


# LICENSES -------------------------------------------------------------------------------------------------------------
# using cpwillis/dots repo secrets, auth and then install into various apps (eg alfred, shottr)


# OS UPDATE/RESTART ----------------------------------------------------------------------------------------------------
if read -rp "$(cecho 'Would you like to install macOS updates and restart? (y/n) ' "$yellow")" response && [[ $response =~ ^[yY]$ ]]; then
    if sudo softwareupdate -l | grep -E '(\*|#) '; then
        sudo softwareupdate -ia --restart
    else
        sudo shutdown -r now
    fi
else
    cecho "All Done! - cpwillis :)" $green
    exit
fi
