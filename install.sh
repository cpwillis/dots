#!/bin/sh

# Define the repository URL
REPO_URL="https://github.com/cpwillis/new-computer.git"

# Define the directory where you want to clone the repository
INSTALL_DIR="$HOME/Downloads/new-computer"

# Clone the repository
echo "Cloning repository..."
git clone "$REPO_URL" "$INSTALL_DIR" || { echo "Failed to clone repository"; exit 1; }

# Change directory to the cloned repository
cd "$INSTALL_DIR" || { echo "Failed to change directory to $INSTALL_DIR"; exit 1; }

# Run setup.sh
if [ -f "setup.sh" ]; then
    echo "Running setup.sh..."
    chmod +x setup.sh
    ./setup.sh || { echo "Failed to execute setup.sh"; exit 1; }
else
    echo "setup.sh not found in the repository."
    exit 1
fi

echo "Installation complete."
