#!/usr/bin/env bash
# full macOS setup - installs packages, applies settings, and deploys dotfiles
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${REPO_DIR}/config"
META_DIR="${REPO_DIR}/meta"

# ── Script Overrides ────────────────────────────────────────────────────────────
# TODO: accept args to run only certain steps e.g. ./install.sh --dotfiles
DRY_RUN=false
for arg in "$@"; do [[ "${arg}" == "--dry-run" ]] && DRY_RUN=true; done


# ── Colors ──────────────────────────────────────────────────────────────────────
black=$(tput setaf 0); red=$(tput setaf 1); green=$(tput setaf 2); yellow=$(tput setaf 3); blue=$(tput setaf 4); magenta=$(tput setaf 5); cyan=$(tput setaf 6); white=$(tput setaf 7); bold=$(tput bold); reset=$(tput sgr0)
cecho() { printf "%s%s%s\n" "${2}" "${1}" "${reset}"; } # $1=msg $2=col

STEP=0
step()  { STEP=$((STEP+1)); printf "\n%s[%s] %s%s\n" "${cyan}${bold}" "${STEP}" "${1}" "${reset}"; }
ok()    { printf "%s    ✓ %s%s\n" "${green}" "${1}" "${reset}"; }
warn()  { printf "%s    ! %s%s\n" "${yellow}" "${1}" "${reset}"; }
run()   { if "${DRY_RUN}"; then printf "%s    ~ %s%s\n" "${cyan}" "$*" "${reset}"; else "$@"; fi; }

trap 'cecho "\nInstallation failed at step ${STEP}. Check the output above." "${red}"; exit 1' ERR

# ── Header ──────────────────────────────────────────────────────────────────────
echo "" # Font: ANSI Shadow (https://www.asciiart.eu/text-to-ascii-art)
cat << 'EOF'
 ██████╗██████╗ ██╗    ██╗██╗██╗     ██╗     ██╗███████╗
██╔════╝██╔══██╗██║    ██║██║██║     ██║     ██║██╔════╝
██║     ██████╔╝██║ █╗ ██║██║██║     ██║     ██║███████╗
██║     ██╔═══╝ ██║███╗██║██║██║     ██║     ██║╚════██║
╚██████╗██║     ╚███╔███╔╝██║███████╗███████╗██║███████║
 ╚═════╝╚═╝      ╚══╝╚══╝ ╚═╝╚══════╝╚══════╝╚═╝╚══════╝
--------------------------------------------------------
          Q U I C K   S E T U P   S C R I P T
EOF

cecho "
*********************************************************
*  WARNING: Review script thoroughly before running.    *
*  Unforeseen changes may occur. Use at your own risk.  *
*********************************************************
" $red # Font: Term

read -rp "$(cecho 'Have you reviewed the script and understood its impact? (y/n) ' "${yellow}")" response
[[ "${response}" =~ ^[yY]$ ]] || { cecho "Aborted." "${red}"; exit 1; }
"${DRY_RUN}" && cecho "\n  DRY RUN - printing commands only, no changes will be made.\n" "${cyan}${bold}"


# ── Sudo keep-alive ─────────────────────────────────────────────────────────────
if ! "${DRY_RUN}"; then
    sudo -v
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi


# ── Homebrew ────────────────────────────────────────────────────────────────────
step "Homebrew"
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null
    # Apple Silicon installs to /opt/homebrew; add to PATH for this session
    if [[ "$(uname -m)" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    ok "Homebrew installed"
else
    ok "Homebrew already installed"
fi
run brew update && run brew upgrade
ok "Homebrew up to date"


# ── Xcode Command Line Tools ────────────────────────────────────────────────────
step "Xcode Command Line Tools"
if xcode-select -p &>/dev/null; then
    ok "Already installed"
else
    run xcode-select --install
    if ! "${DRY_RUN}"; then
        cecho "    Waiting for Xcode CLT to finish..." "${yellow}"
        until xcode-select -p &>/dev/null; do sleep 5; done
    fi
    ok "Installed"
fi


# ── Brew Bundle ─────────────────────────────────────────────────────────────────
step "Installing packages (Brewfile)"
open -a "App Store"
while true; do
    read -rp "$(cecho '    Sign in to the App Store to enable MAS installs. Ready? (y/n) ' "${yellow}")" r
    [[ "${r}" =~ ^[yY]$ ]] && break
    warn "Sign in and press y, or Ctrl+C to skip"
done
run brew bundle --file="${CONFIG_DIR}/Brewfile" --no-lock
run brew cleanup
ok "All packages installed"


# ── Oh My Zsh ───────────────────────────────────────────────────────────────────
step "Oh My Zsh"
if [ -d "${HOME}/.oh-my-zsh" ]; then
    ok "Already installed"
else
    if "${DRY_RUN}"; then
        cecho "    ~ RUNZSH=no CHSH=no sh -c \$(curl ohmyzsh/install.sh)" "${cyan}"
    else
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    ok "Installed"
fi


# ── macOS Settings ──────────────────────────────────────────────────────────────
step "macOS settings"
# Close System Settings to prevent overrides
run osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true
run osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

if [ -f "${META_DIR}/macOS_settings.sh" ]; then
    while IFS= read -r line; do
        [[ "${line}" =~ ^[[:space:]]*#|^[[:space:]]*$ ]] && continue
        run eval "${line}"
    done < "${META_DIR}/macOS_settings.sh"
    ok "Settings applied"
else
    warn "macOS settings file not found - skipping"
fi

# Remove unwanted stock Apple apps
for app in "GarageBand" "Pages" "Numbers" "Keynote"; do
    if [ -d "/Applications/${app}.app" ]; then
        run sudo rm -rf "/Applications/${app}.app"
        ok "Removed ${app}"
    fi
done


# ── Dotfiles ────────────────────────────────────────────────────────────────────
step "Deploying dotfiles"
while IFS=',' read -r name repo_path system_path; do
    name=$(printf '%s' "${name}" | tr -d '"' | xargs)
    repo_path=$(printf '%s' "${repo_path}" | tr -d '"' | xargs)
    system_path=$(printf '%s' "${system_path}" | tr -d '"' | xargs)

    src="${REPO_DIR}/${repo_path}"
    dst=$(eval echo "${system_path}")

    if [ ! -f "${src}" ]; then
        warn "${name}: source not found (${repo_path})"
        continue
    fi
    run mkdir -p "$(dirname "${dst}")"
    run cp "${src}" "${dst}"
    ok "${name} → ${dst}"
done < <(grep -v '^[[:space:]]*#\|^[[:space:]]*$' "${META_DIR}/manifest.csv")


# ── GitHub SSH Keys ─────────────────────────────────────────────────────────────
# TODO: generate SSH keys & add to ssh-agent, add SSH key to GitHub via API


# ── Licenses ────────────────────────────────────────────────────────────────────
# TODO: using cpwillis/dots repo secrets, auth and install into apps (Alfred, Shottr, BetterDisplay, CleanMyMac X, Bruno)


# ── Default Shell ───────────────────────────────────────────────────────────────
step "Default shell"
if [[ "${SHELL}" != "/bin/zsh" ]]; then
    run chsh -s /bin/zsh
    ok "Default shell set to zsh"
else
    ok "Already zsh"
fi


# ── macOS Software Update ───────────────────────────────────────────────────────
printf "\n"
read -rp "$(cecho 'Install macOS updates and restart now? (y/n) ' "${yellow}")" r
if [[ "${r}" =~ ^[yY]$ ]]; then
    run sudo softwareupdate -ia --restart
fi

printf "\n%sAll done! - cpwillis :)%s\n\n" "${green}${bold}" "${reset}"
