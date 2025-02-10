# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(                   # https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
    z                       # shortcut to most visited dirs
    colored-man-pages       # colorize man pages
    python                  # py aliases
    last-working-dir        # new shells open in lwd
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
alias gp='git diff --quiet && git pull || (git stash push && git pull && git stash pop)'
alias todo='git diff -U0 main.. | awk '\''/^diff --git/{file=$3;sub(/^a\//,"",file);rel_path=file;gsub(/.*\//,"",file)} /^@@/{start=$2;sub(/^[^+]*[+]/,"",start);linenum=int(start);linenum=linenum>0?linenum:-linenum;next} /^+.*(TODO|FIXME|BUG|NOTE|MISC)/{gsub(/^[+ ]+/,"",$0);split($0,arr,"#");code=arr[1];comment=arr[2];gsub(/^ +| +$/,"",code);gsub(/^ +| +$/,"",comment);col_1=rel_path":"linenum;if(length(code)>0){col_1=col_1"\x1b[35m|\x1b[0m"code}printf "%s\x1b[35m|\x1b[0m%s\n",col_1,comment} /^[^-]/{linenum++}'\'' | sed -E '\''s/(TODO.*)/\x1b[33m\1\x1b[0m/g;s/(FIXME.*)/\x1b[35m\1\x1b[0m/g;s/(BUG.*)/\x1b[31m\1\x1b[0m/g;s/(NOTE.*)/\x1b[94m\1\x1b[0m/g;s/(MISC.*)/\x1b[32m\1\x1b[0m/g'\'''
alias remote='gh pr view --web || gh repo view --web -b "$(git branch --show-current)"'

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
alias b='brew'
alias h='history'
alias cl='clear'
alias rm='rm -i' # prompt before deleting
alias mv='mv -i' # prompt before overwriting
alias sudo='sudo ' # attempt alias expansion

# Work
alias sc='f() { story_id=${1:-$(git rev-parse --abbrev-ref HEAD | grep -o "sc-[0-9]*" | grep -o "[0-9]*")}; if [ -n "$story_id" ]; then open "https://app.shortcut.com/tour-amigo/story/$story_id"; else echo "No Shortcut ID found."; fi; }; f'
alias startmyday='brewup && open -a Docker && z zeus && g co main && g pull && ctl up -d --build && ctl post-deploy' # no unstaged changes required

# Tools
eval $(thefuck --alias)
eval "$(direnv hook zsh)" # auto load .env
eval "$(atuin init zsh)"
export GPG_TTY=$(tty) # ttl in ~/.gnupg/gpg-agent.conf (5hrs)

# Colors (using brew coreutils)
# test -r ~/.dircolors && eval $(gdircolors ~/.dircolors)

# Versioning
alias python=python3
alias pip=pip3
