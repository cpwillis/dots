# Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(                   # https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
    z                       # shortcut to most visited dirs
    aliases                 # list available aliases with `als`
    colored-man-pages       # colorize man pages
    command-not-found       # suggest packages when command not found
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

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Git
alias gp='git pull'
alias todo='git diff -U0 main.. | awk "/^@@/ {start=\$2; sub(/^[^+]*[+]/, \"\", start); next} /^+.*TODO/ {gsub(/^[+ ]+/, \"\", \$0); print \$0}" | sed -E "s/(# TODO.*)/\x1b[31m\1\x1b[0m/"'
alias remote='gh pr view --web || gh repo view --web -b "$(git branch --show-current)"'
alias sc='branch=$(git rev-parse --abbrev-ref HEAD); if [[ $branch =~ sc-([0-9]+) ]]; then story_id=$match[1]; open https://app.shortcut.com/tour-amigo/story/$story_id; else echo "No Shortcut story ID found in branch name."; fi'
alias mainpull="git checkout main && git pull"
alias mainpullmerge="git checkout main && git pull && git checkout - && GIT_MERGE_AUTOEDIT=no git merge main"

# Docker
alias dockerps="docker ps --format 'table {{.Names}}\t{{.Ports}}\t{{.Status}}\t{{.CreatedAt}}'"
alias dockersv='echo "CONTAINER ID \t NAME \t\t SERVICE" && docker ps -q | while read -r container_id; do service=$(docker inspect --format "{{ index .Config.Labels \"com.docker.compose.service\" }}" "$container_id"); name=$(docker inspect --format "{{ .Name }}" "$container_id" | sed "s/\///g"); echo "$container_id \t $name \t $service"; done'
alias dockerinfo="dockerps; echo ''; dockersv"

# Helpers
alias brewup="brew update && brew upgrade && brew cleanup && brew doctor"
alias uuid='c=${1:-1};python3 -c "import timeflake" >/dev/null 2>&1||{ echo -n "Install timeflake? [y/n] ";read -r i;[ "$i" != "y" ]&&exit;pip3 install timeflake;};for ((j=0;j<c;j++));do python3 -c "import timeflake;print(timeflake.random().hex.lower())";done' # Generate Timeflake UUID
alias zsql="mycli -uroot -proot_password -P3307 -h127.0.0.1"

# Misc
alias g='git'
alias h='history'
alias cl='clear'
alias rm='rm -i' # prompt before deleting
alias mv='mv -i' # prompt before overwriting
alias sudo='sudo ' # attempt alias expansion

# Tools
eval $(thefuck --alias)
eval "$(direnv hook zsh)"
eval "$(atuin init zsh)"
export GPG_TTY=$(tty) # ttl in ~/.gnupg/gpg-agent.conf

# Colors (using brew coreutils)
# test -r ~/.dircolors && eval $(gdircolors ~/.dircolors)

# Versioning
alias python=python3
alias pip=pip3

# Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
