#!/bin/sh
# script to update config files in the repo from the system

# repo config folder
CONFIG_DIR="$(cd "$(dirname "$0")/../config" && pwd)"

# vscode
cp ~/Library/Application\ Support/Code/User/settings.json "$CONFIG_DIR/vscode/settings.json"
cp ~/Library/Application\ Support/Code/User/snippets/python.json "$CONFIG_DIR/vscode/snippets-python.json"
echo "vscode updated"

# gitconfig, email and signingkey are placeholders
cp ~/.gitconfig "$CONFIG_DIR/.gitconfig"
sed -i '' 's/email = .*/email = <github_no_reply>/g' "$CONFIG_DIR/.gitconfig"
sed -i '' 's/signingkey = .*/signingkey = <public_key>/g' "$CONFIG_DIR/.gitconfig"
echo "gitconfig updated"

# zshrc
cp ~/.zshrc "$CONFIG_DIR/.zshrc"
echo "zshrc updated"

# brewfile, sometimes MAS items are missing upon dump, check and loop
for i in {1..3}; do
    brew bundle dump --file="$CONFIG_DIR/Brewfile" --force
    grep -q "^mas " "$CONFIG_DIR/Brewfile" && break
    [[ $i -lt 3 ]] && echo "MAS items missing, retrying... (Attempt $((i+1)) of 3)" && brew reinstall mas
done
[[ $i -eq 3 && ! $(grep -q "^mas " "$CONFIG_DIR/Brewfile") ]] && echo "Warning: MAS items are still missing after 3 attempts." || echo "brewfile updated (w/ mas items)"

# push update to repo
cd "$(dirname "$CONFIG_DIR")" && git add . && git commit -m "run update" && git push
echo "changes pushed to git"

# fin
echo "--> quick_update.sh completed successfully!"
