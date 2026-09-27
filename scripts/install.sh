#!/usr/bin/env bash
# full macOS setup - installs packages, applies settings, and deploys dotfiles
set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${REPO_DIR}/config"
META_DIR="${REPO_DIR}/meta"
STATE_FILE="${HOME}/.local/state/dots/install-done" # finished steps, one per line; outside the repo so reclones keep it
FAILED_FILE="${HOME}/.local/state/dots/packages-failed" # Brewfile items brew bundle couldn't install, shown at the end
STEPS=(homebrew packages omz macos dotfiles ssh shell update)

# ── Script Overrides ────────────────────────────────────────────────────────────
usage() { printf 'usage: install.sh [--dry-run] [--fresh] [--only step,...] [--skip step,...]\nsteps: %s\n' "${STEPS[*]}"; }
DRY_RUN=false; FRESH=false; ONLY=""; SKIP=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true ;;
        --fresh)   FRESH=true ;;
        --only)    ONLY="${2:?--only needs a step list}"; shift ;;
        --skip)    SKIP="${2:?--skip needs a step list}"; shift ;;
        -h|--help) usage; exit 0 ;;
        *)         usage; exit 1 ;;
    esac
    shift
done
for s in ${ONLY//,/ } ${SKIP//,/ }; do
    [[ " ${STEPS[*]} " == *" ${s} "* ]] || { printf 'unknown step: %s\n' "${s}"; usage; exit 1; }
done


# ── Colors ──────────────────────────────────────────────────────────────────────
red=$(tput setaf 1); green=$(tput setaf 2); yellow=$(tput setaf 3); cyan=$(tput setaf 6); bold=$(tput bold); reset=$(tput sgr0)
cecho() { printf "%s%b%s\n" "${2}" "${1}" "${reset}"; } # $1=msg (\n expanded) $2=col

STEP=0
CURRENT=""
step()  { STEP=$((STEP+1)); printf "\n%s[%s] %s%s\n" "${cyan}${bold}" "${STEP}" "${1}" "${reset}"; }
ok()    { printf "%s    ✓ %s%s\n" "${green}" "${1}" "${reset}"; }
warn()  { printf "%s    ! %s%s\n" "${yellow}" "${1}" "${reset}"; }
run()   { if "${DRY_RUN}"; then printf "%s    ~ %s%s\n" "${cyan}" "$*" "${reset}"; else "$@"; fi; }
in_list()  { [[ ",${2}," == *",${1},"* ]]; }
recorded() { grep -qsx "${1}" "${STATE_FILE}"; }
is_done()  { ! "${FRESH}" && recorded "${1}"; }

trap 'cecho "\nFailed during the ${CURRENT:-setup} step. Check the output above, then rerun to resume." "${red}"; exit 1' ERR
trap 'cecho "\nInterrupted during the ${CURRENT:-setup} step. Rerun to resume." "${yellow}"; exit 130' INT

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
    # no stdout: a held pipe would stall `install.sh | tee` for up to 60s after it finishes
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done &>/dev/null &
fi


# ── Homebrew ────────────────────────────────────────────────────────────────────
step_homebrew() {
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
}


# ── Brew Bundle ─────────────────────────────────────────────────────────────────
step_packages() {
    step "Installing packages (Brewfile)"
    open -a "App Store"
    while true; do
        read -rp "$(cecho '    Sign in to the App Store to enable MAS installs. Ready? (y/n) ' "${yellow}")" r
        [[ "${r}" =~ ^[yY]$ ]] && break
        warn "Sign in and press y, or Ctrl+C and rerun with --skip packages"
    done
    local log; log=$(mktemp)
    "${DRY_RUN}" || rm -f "${FAILED_FILE}"
    # an item that fails (eg a cask Homebrew disabled) is skipped and listed at the end; any other failure stops here
    # </dev/null: installers it runs must not read answers meant for later prompts
    # stdout stays on the terminal so output is live; only stderr, where failures go, is copied to the log
    if ! { run brew bundle --file="${CONFIG_DIR}/Brewfile" </dev/null 2>&1 1>&3 3>&- | tee "${log}" >&2; } 3>&1; then
        grep -o '[A-Z][a-z]* .* has failed!' "${log}" | sed 's/^[A-Za-z]* //; s/ has failed!$//' > "${FAILED_FILE}" || true
        [[ -s "${FAILED_FILE}" ]] || { rm -f "${log}"; return 1; }
        warn "Skipped, could not install: $(paste -sd, "${FAILED_FILE}" | sed 's/,/, /g')"
    fi
    rm -f "${log}"
    run brew cleanup
    ok "Packages installed"
}


# ── Oh My Zsh ───────────────────────────────────────────────────────────────────
step_omz() {
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

    plugin_dir="${HOME}/.oh-my-zsh/custom/plugins/omz-git-branch"
    if [ -d "${plugin_dir}" ]; then
        ok "omz-git-branch already installed"
    else
        # skip ~/.gitconfig so its https->ssh rewrite can't require SSH keys
        run env GIT_CONFIG_GLOBAL=/dev/null git clone https://github.com/cpwillis/omz-git-branch.git "${plugin_dir}"
        ok "omz-git-branch installed"
    fi
}


# ── macOS Settings ──────────────────────────────────────────────────────────────
step_macos() {
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
}


# ── Dotfiles ────────────────────────────────────────────────────────────────────
step_dotfiles() {
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
    done < <(grep -v '^[[:space:]]*#\|^[[:space:]]*$\|^name,' "${META_DIR}/manifest.csv")
}


# ── GitHub SSH Key ──────────────────────────────────────────────────────────────
step_ssh() {
    step "GitHub SSH key"
    if [ -f "${HOME}/.ssh/id_ed25519" ]; then
        ok "Already exists"
    else
        # gh generates the key and uploads it to GitHub as part of login
        run gh auth login --hostname github.com --git-protocol ssh --web
        ok "Key generated and added to GitHub"
    fi
}


# ── Default Shell ───────────────────────────────────────────────────────────────
step_shell() {
    step "Default shell"
    if [[ "${SHELL}" != "/bin/zsh" ]]; then
        run chsh -s /bin/zsh
        ok "Default shell set to zsh"
    else
        ok "Already zsh"
    fi
}


# ── macOS Software Update ───────────────────────────────────────────────────────
step_update() {
    step "macOS updates"
    read -rp "$(cecho '    Install macOS updates and restart now? (y/n) ' "${yellow}")" r
    if [[ "${r}" =~ ^[yY]$ ]]; then
        run sudo softwareupdate -ia --restart
    fi
}


# ── Run steps ───────────────────────────────────────────────────────────────────
if ! "${DRY_RUN}"; then
    mkdir -p "$(dirname "${STATE_FILE}")"
    if "${FRESH}"; then rm -f "${STATE_FILE}"; fi
fi
if [[ -z "${ONLY}" ]] && ! "${FRESH}" && [[ -s "${STATE_FILE}" ]]; then
    cecho "\n  Resuming, already done: $(paste -sd' ' "${STATE_FILE}"). Use --fresh to rerun everything." "${cyan}"
fi

ran=0
for s in "${STEPS[@]}"; do
    if [[ -n "${ONLY}" ]]; then
        in_list "${s}" "${ONLY}" || continue
    elif in_list "${s}" "${SKIP}" || is_done "${s}"; then
        continue
    fi
    CURRENT="${s}"
    "step_${s}"
    if ! "${DRY_RUN}" && ! recorded "${s}"; then echo "${s}" >> "${STATE_FILE}"; fi
    ran=$((ran+1))
done
CURRENT=""

if [[ -s "${FAILED_FILE}" ]]; then
    cecho "\nNot installed by brew bundle: $(paste -sd, "${FAILED_FILE}" | sed 's/,/, /g')." "${yellow}"
    cecho "Fix or install by hand, then rerun with --only packages." "${yellow}"
fi

left=""
for s in "${STEPS[@]}"; do recorded "${s}" || left+="${s} "; done
if ! "${DRY_RUN}" && [[ -n "${left}" ]]; then
    cecho "\nStill to do: ${left% }. Rerun to finish." "${yellow}"
elif [[ "${ran}" -eq 0 ]]; then
    cecho "\nNothing to run, every step is done. Use --fresh or --only <step> to rerun." "${cyan}"
else
    printf "\n%sAll done! - cpwillis :)%s\n\n" "${green}${bold}" "${reset}"
fi
