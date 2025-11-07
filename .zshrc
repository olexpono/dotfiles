# GITHUB CODESPACES SPECIFIC
DISABLE_AUTO_UPDATE=true
DISABLE_UPDATE_PROMPT=true

alias ops=<<EOALIAS
echo
spp = "git pull && just post-pull && just dev-replace-web"
wtests = "just unit-test-project web-client"
wtc = "just turbo typecheck -F @vanta/web-client"
wlint = "just turbo lint -F @vanta/web-client"
webdev = "just dev-start web-client"
sbook = "just dev-storybook"
EOALIAS

alias spp="git pull && just post-pull && just dev-replace-web"
alias wtests="just unit-test-project web-client"
alias wtc="just turbo typecheck -F @vanta/web-client"
alias wlint="just turbo lint -F @vanta/web-client"
alias wlogs="just dev-watch-logs web-client"
alias webdev="just dev-start web-client"
alias sbook="just dev-storybook"

mux() {
    if ! command -v tmux &> /dev/null; then
        echo "Error: tmux is not installed"
        return 1
    fi

    if [ -n "$TMUX" ]; then
        echo "Already inside a tmux session"
        return 0
    fi

    # If an argument is provided, use it as the session name
    local session_name="$1"

    # Help
    if [ "$session_name" = "-h" ] || [ "$session_name" = "--help" ]; then
        echo "mux [session]: Entry point into tmux"
        echo " $ mux            - connects to any running session, else creates [0]"
        echo " $ mux [session]  - attempts to connect to [session] if exists, else starts it"
        return 0
    fi

    if [ -n "$session_name" ]; then
        # Try to attach to named session, create if it doesn't exist
        tmux attach-session -t "$session_name" 2>/dev/null || tmux new-session -s "$session_name"
    else
        # No argument - attach to any existing session or create a new one
        if tmux list-sessions &> /dev/null; then
            tmux attach-session
        else
            tmux new-session
        fi
    fi
}

# ----- USUAL zshrc ------- #
# Clone antidote if necessary.
[[ -e ${ZDOTDIR:-~}/.antidote ]] ||
  git clone https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote

# Source antidote.
source ${ZDOTDIR:-~}/.antidote/antidote.zsh

# Initialize antidote's dynamic mode, which changes `antidote bundle`
# from static mode.
source <(antidote init)

# Bundle Fish-like auto suggestions just like you would with antigen.
antidote bundle zsh-users/zsh-autosuggestions

# Bundle extra zsh completions too.
antidote bundle zsh-users/zsh-completions

# Antidote doesn't have the 'use' command like antigen,
# but instead you can accomplish the same via annotations:

# Bundle oh-my-zsh libs and plugins with the 'path:' annotation
antidote bundle getantidote/use-omz

antidote bundle https://gist.github.com/tholex/07cefba1da02382f64f5 path:agnoster-cs.zsh-theme

# OR - you might want to load bundles with a HEREDOC.
antidote bundle <<EOBUNDLE
    # Bundle syntax-highlighting
    zsh-users/zsh-syntax-highlighting

    # Bundle OMZ plugins using annotations
    ohmyzsh/ohmyzsh path:plugins/fancy-ctrl-z
    ohmyzsh/ohmyzsh path:plugins/gh

    ohmyzsh/ohmyzsh path:lib
    ohmyzsh/ohmyzsh path:plugins/git
    ohmyzsh/ohmyzsh path:plugins/git-extras
    ohmyzsh/ohmyzsh path:plugins/extract
    ohmyzsh/ohmyzsh path:plugins/command-not-found
    ohmyzsh/ohmyzsh path:plugins/isodate
    ohmyzsh/ohmyzsh path:plugins/volta
    ohmyzsh/ohmyzsh path:plugins/npm
    ohmyzsh/ohmyzsh path:plugins/yarn

    # Bundle with a git URL
    https://github.com/zsh-users/zsh-history-substring-search
EOBUNDLE

# PATH and HOME dirs
export GOPATH=$HOME/go
export JAVA_HOME="/Library/Java/Home"

export PATH=$PATH:/bin:/usr/sbin:/sbin:/usr/bin:~/go/bin:/usr/local/git/bin
export PATH="$HOME/.cargo/bin:$PATH"

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# RIPGREP
export RIPGREP_CONFIG_PATH="$HOME/.rgconfig"

# GIT_EDITOR ETC
export TERM=xterm-256color
export EDITOR='vim'
export GIT_EDITOR='vim'
export DEFAULT_USER='olex'

# Use default port for postgres
export PGPORT=5432

# GPG tty
export GPG_TTY=$(tty)

# export PGDATA=/usr/local/postgres
#

# keybindings
#
# fn-left and fn-right (home & end)
bindkey '\e[4~' end-of-line
bindkey '\e[1~' beginning-of-line

# aliases

alias xcommit="git commit --no-gpg-sign"
# alias nuke-reinstall="rm -rf node_modules/ && npm install && npm run build"
# alias nuke-reinstall="npm clean-install"

alias branchpurge="git branch --merged | grep -v \"\*\" | xargs -n 1 git branch -d"

alias ack="noglob rg"

alias to="source ~/.zshrc"

# tmux
alias tl="tmux list-sessions"
alias td="tmux detach"

# git
alias gg="git status"
alias gb="git branch"
alias gsm="git checkout main; git pull; git checkout -"
# alias grm="git checkout main; git pull; git checkout -; git rebase -i main"

function rootcommit() {
  git log -1 &> /dev/null
  if [ $? -eq 0 ];
  then
    echo 'No commit created, looks like this is a non-empty git repo.'
  else
    git reset *
    git commit --allow-empty -m "Root commit"
  fi;
}

function attach () { tmux attach -t "$@" }

red=$'\e[0;31m'
red2=$'\e[0;35m'
yellow=$'\e[0;33m'
yellow2=$'\e[0;36m'
reset="\e[0m"
echo -e "\n  ${yellow}C O D E${reset}\n  ${red}S P A C E S${reset}\n${yellow}-${red}-${red2}-${yellow2}-${red2}-${red}-${yellow}-${red}-${red2}-${yellow2}-${red2}-${red}-${yellow}-${reset}"

function lf() {
    if [ -z "$1" ]
    then
      ll
    else
      ls -1 **/*"$@"*
    fi
}
function hgrep() {
    if [ -z "$1" ]
    then
        fc -l 1
    else
        fc -l 1 | grep "$@"
    fi
}

function bgrep() {
    if [ -z "$1" ]
    then
      git branch
    else
      git branch | grep "$@"
    fi
}

function poop() {
  if [[ -z $2 ]]
  then
    ps -alx | grep -v grep | grep "$@" | awk '{print $2, "💩   ", $15, $16}'
  else
    ps -alx | awk '{print $2}'
  fi
}

