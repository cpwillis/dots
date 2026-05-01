#!/usr/bin/env bash
# clone the repo and run the installer
set -euo pipefail

REPO_URL="https://github.com/cpwillis/dots.git"
INSTALL_DIR="${HOME}/Downloads/dots"

# Remove existing directory if present
if [ -d "${INSTALL_DIR}" ]; then
    printf "Directory already exists at %s.\n" "${INSTALL_DIR}"
    read -rp "Remove it and continue? (y/n) " reply
    case "$(printf '%s' "${reply}" | tr '[:upper:]' '[:lower:]')" in
        y|yes)
            rm -rf "${INSTALL_DIR}"
            printf "Removed existing directory.\n"
            ;;
        *)
            printf "Cancelled.\n"
            exit 1
            ;;
    esac
fi

# Clone and run installer
printf "Cloning %s...\n" "${REPO_URL}"
git clone "${REPO_URL}" "${INSTALL_DIR}"

cd "${INSTALL_DIR}"
chmod +x scripts/install.sh
./scripts/install.sh
