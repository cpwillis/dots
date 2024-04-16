#!/bin/sh

# Define the repository URL
REPO_URL="https://github.com/cpwillis/new-mac.git"

# Define the directory where you want to clone the repository
INSTALL_DIR="$HOME/Downloads/new-mac"

# If the installation directory already exists, prompt the user to remove it
if [ -d "$INSTALL_DIR" ]; then
    printf "The installation directory already exists at %s.\n" "$INSTALL_DIR"
    printf "Do you want to remove it and proceed with the installation? (y/n) "
    read -r REPLY
    case "$(printf "%s" "$REPLY" | tr '[:upper:]' '[:lower:]')" in
    y | yes)
        rm -rf "$INSTALL_DIR" || {
            echo "Failed to remove the existing directory. Check your permissions." >&2
            exit 1
        }
        printf "Existing installation directory removed successfully.\n"
        ;;
    *)
        echo "Installation cancelled by the user."
        exit 1
        ;;
    esac
fi

# Clone the repository
echo "Cloning repository..."
git clone "$REPO_URL" "$INSTALL_DIR" || { echo "Failed to clone repository"; exit 1; }

# Change directory to the cloned repository
cd "$INSTALL_DIR" || { echo "Failed to change directory to $INSTALL_DIR"; exit 1; }

# Run setup.sh
if [ -f "setup.sh" ]; then
    echo "Running setup.sh..."
    chmod +x setup.sh
    ./setup.sh
else
    echo "setup.sh not found in the repository."
    exit 1
fi
