#!/usr/bin/env bash
# sync current system configs back to the repo
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG_DIR="${REPO_DIR}/config"
META_DIR="${REPO_DIR}/meta"

# ── Colors ──────────────────────────────────────────────────────────────────────
green=$(tput setaf 2); yellow=$(tput setaf 3); cyan=$(tput setaf 6)
bold=$(tput bold); reset=$(tput sgr0)
ok()   { printf "%s    ✓ %s%s\n" "${green}" "${1}" "${reset}"; }
warn() { printf "%s    ! %s%s\n" "${yellow}" "${1}" "${reset}"; }
info() { printf "\n%s%s%s\n" "${cyan}${bold}" "${1}" "${reset}"; }


# ── Dotfiles from manifest.csv ──────────────────────────────────────────────────
info "Dotfiles"
while IFS=',' read -r name repo_path system_path; do
    name=$(printf '%s' "${name}" | tr -d '"' | xargs)
    repo_path=$(printf '%s' "${repo_path}" | tr -d '"' | xargs)
    system_path=$(printf '%s' "${system_path}" | tr -d '"' | xargs)

    src=$(eval echo "${system_path}")
    dst="${REPO_DIR}/${repo_path}"

    if [ ! -f "${src}" ]; then
        warn "${name}: not found at ${src}"
        continue
    fi
    mkdir -p "$(dirname "${dst}")"
    cp "${src}" "${dst}"
    ok "${name}"
done < <(grep -v '^[[:space:]]*#\|^[[:space:]]*$' "${META_DIR}/manifest.csv")


# ── Sanitize .gitconfig ─────────────────────────────────────────────────────────
info "Sanitizing .gitconfig"
sed -i '' 's/email = .*/email = <github_no_reply>/g' "${CONFIG_DIR}/.gitconfig"
sed -i '' 's/signingkey = .*/signingkey = <public_key>/g' "${CONFIG_DIR}/.gitconfig"
ok "email and signingkey redacted"


# ── Brewfile ────────────────────────────────────────────────────────────────────
info "Brewfile"
for i in 1 2 3; do
    brew bundle dump --file="${CONFIG_DIR}/Brewfile" --force
    if grep -q '^mas ' "${CONFIG_DIR}/Brewfile"; then
        ok "Brewfile updated (with MAS entries)"
        break
    fi
    if [ "${i}" -lt 3 ]; then
        warn "MAS entries missing - retrying (attempt $((i+1))/3)"
        brew reinstall mas
    else
        warn "MAS entries still missing after 3 attempts"
    fi
done


# ── Git commit + push ───────────────────────────────────────────────────────────
if [[ "${1:-}" == "--commit" ]]; then
    info "Committing and pushing"
    cd "${REPO_DIR}"
    git add .
    git commit -m "run update"
    git push
    ok "Changes pushed to remote"
else
    info "Skipping commit - pass --commit to auto-push"
fi

printf "\n%s✓ update_configs.sh complete%s\n\n" "${green}${bold}" "${reset}"
