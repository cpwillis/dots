# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"

export ZSH="$HOME/.oh-my-zsh" #Installation Path

ZSH_THEME="robbyrussell"

# https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
plugins=( 
    omz-git-branch # https://github.com/cpwillis/omz-git-branch
    python # aliases
    git # aliases/functions
    z # shortcut to most visited dirs
    thefuck # corrects commands
    zsh-autosuggestions # Custom: https://github.com/zsh-users/zsh-autosuggestions/
    last-working-dir # lwd, keeps track of last working dir
    dotenv # automatically load .env variables from current dir
    web-search # search the web
)

alias python=python3
alias pip=pip3

source $ZSH/oh-my-zsh.sh
source /Users/cpw/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh #https://github.com/zsh-users/zsh-syntax-highlighting

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
