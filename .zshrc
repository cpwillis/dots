# CodeWhisperer pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(
    git                     # aliases/functions
    python                  # aliases
    omz-git-branch          # limit git branch name
    z                       # shortcut to most visited dirs
    last-working-dir        # lwd, keeps track of last working dir
    web-search              # search the web
)
source $ZSH/oh-my-zsh.sh

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
alias remote='open "$(git remote get-url origin | sed "s/\.git$//")"' # open git remote in browser
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
eval $(thefuck --alias)
eval "$(direnv hook zsh)"
export GPG_TTY=$(tty)

# CodeWhisperer post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh"
