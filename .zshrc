# Root of this dotfiles checkout, found by following this file's own symlink.
# Tools that rewrite ~/.zshrc (temp file + rename) replace the symlink with a
# copy, which makes the self-resolution point at $HOME; fall back to the usual
# checkout locations in that case.
export DOTFILES_DIR=${${(%):-%N}:A:h}
if [[ ! -d $DOTFILES_DIR/themes ]]; then
  for _d in ~/dotfiles /workspaces/dotfiles; do
    [[ -d $_d/themes ]] && export DOTFILES_DIR=${_d:A} && break
  done
  unset _d
fi

# work.zsh sets DISABLE_AUTO_UPDATE etc, so it must load before the
# antidote/oh-my-zsh bundles below.
# $CODESPACES is only set in real Codespaces, not in a local/remote devcontainer,
# so also key off the checkout work.zsh is hard-coded against.
if [[ -n "$CODESPACES" || -d /workspaces/obsidian ]]; then
  source $DOTFILES_DIR/work.zsh
fi
source $DOTFILES_DIR/personal.zsh

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

# Theme now lives in this repo (was gist tholex/07cefba1da02382f64f5).
# Raw: https://raw.githubusercontent.com/olexpono/dotfiles/main/themes/agnoster-cs.zsh-theme
# antidote git-clones any URL, so it can't bundle a raw file: source it from
# the repo instead.
_dotfiles_theme=$DOTFILES_DIR/themes/agnoster-cs.zsh-theme
if [[ -r $_dotfiles_theme ]]; then
  source $_dotfiles_theme
else
  echo "warning: theme not found at $_dotfiles_theme (git pull the dotfiles checkout)" >&2
fi
unset _dotfiles_theme

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

# FIX TMUX ENCODING
export LANG=en_US.UTF-8

# COLORS / THEMING
export LS_COLORS="${LS_COLORS}:ow=1;35"

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
