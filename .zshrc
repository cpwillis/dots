# Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(
    z                       # shortcut to most visited dirs
    git                     # aliases/functions
    python                  # aliases
    last-working-dir        # lwd, keeps track of last working dir
    web-search              # search the web
    omz-git-branch          # limit git branch name, https://github.com/cpwillis/omz-git-branch
)
source $ZSH/oh-my-zsh.sh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # https://github.com/zsh-users/zsh-syntax-highlighting
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh # https://github.com/zsh-users/zsh-autosuggestions

# Open VSCode Workspace if Available
code_path="$(command -v code)"
code() {
    local project_dir=$(realpath "$1")
    local project_name=$(basename "$project_dir")
    [[ -f "$project_dir/.vscode/$project_name.code-workspace" ]] && { echo "Found $project_name.code-workspace, opening that instead..."; "$code_path" "$project_dir/.vscode/$project_name.code-workspace"; return; }
    "$code_path" "$@"
}

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Misc
alias python=python3
alias pip=pip3
alias remote='gh pr view --web || open "$(git remote get-url origin | sed "s/\.git$//" | awk -v branch=$(git rev-parse --abbrev-ref HEAD) "{print \$0 \"/tree/\" branch}")"' # Open PR else Branch URL
alias uuid='c=${1:-1};python3 -c "import timeflake" >/dev/null 2>&1||{ echo -n "Install timeflake? [y/n] ";read -r i;[ "$i" != "y" ]&&exit;pip3 install timeflake;};for ((j=0;j<c;j++));do python3 -c "import timeflake;print(timeflake.random().hex.lower())";done' # Generate Timeflake UUID
eval $(thefuck --alias)
eval "$(direnv hook zsh)"
eval "$(atuin init zsh)"
export GPG_TTY=$(tty)

# Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
