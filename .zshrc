# GITHUB CODESPACES SPECIFIC
DISABLE_AUTO_UPDATE=true
DISABLE_UPDATE_PROMPT=true
export GITHUB_USER="olexpono"

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

ops() {
  cat <<EOALIAS
Shorthand commands:

  spp      Pull, post-pull, and replace web   (git pull && just post-pull && just dev-replace-web)
  wtests   Run web-client unit tests          (just unit-test-project web-client)
  wtc      Typecheck web-client               (just turbo typecheck -F @vanta/web-client --continue)
  wlint    Lint web-client                    (just turbo lint -F @vanta/web-client --continue)
  wlogs    Tail web dev logs                  (just dev-watch-logs web)
  webdev   Start web dev server               (just dev-start-web)
  webz     Start web against staging          (just dev-web-staging)
  sbook    Start Storybook                    (just dev-storybook)
  static   Run static analysis across project (npx turbo run project-static-analysis ...)
  alpstat  Analyze + serve alpaca playground  (site:install if needed, then generate && serve)
  cl       Claude Code in auto mode           (claude --permission-mode=auto)
  bop      Group my open PRs by readiness     (pr-status.py [branch-prefix])
EOALIAS
}

alias spp="git pull && just post-pull && just dev-replace-web"
alias wtests="just unit-test-project web-client"
alias wtc="just turbo typecheck -F @vanta/web-client"
alias static="npx turbo run project-static-analysis --concurrency=16 --log-order=stream --continue --summarize"
alias wlint="just turbo lint -F @vanta/web-client"
alias wlogs="just dev-watch-logs web"
alias webdev="just dev-start-web"
alias webz="just dev-web-staging"
alias sbook="just dev-storybook"
alias cl="claude --permission-mode=auto"
alias bop="python3 $DOTFILES_DIR/.local/bin/pr-status.py"

# The playground's minisite lives outside the pnpm workspace, so `pnpm install`
# never fetches its deps; install them on first run, then generate and serve.
# alpstat was an alias until 2026-09; zsh expands aliases at parse time, so
# re-sourcing into a shell that still has it fails without this unalias.
unalias alpstat 2>/dev/null
alpstat() {
  local pkg=@vanta/alpaca-static-analysis-playground
  local site="$(git rev-parse --show-toplevel 2>/dev/null)/scripts/alpaca-static-analysis-playground/site"
  if [[ ! -d $site ]]; then
    echo "alpstat: run from inside the teal checkout (no $site)" >&2
    return 1
  fi
  if [[ ! -d $site/node_modules ]]; then
    pnpm --filter $pkg site:install || return 1
  fi
  pnpm --filter $pkg generate && pnpm --filter $pkg serve
}

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

riptoken() {
  emulate -L zsh
  local token="$1"
  if [[ -z "$token" ]]; then
    echo "usage: riptoken <token>  (e.g. riptoken bg.neutral.default)" >&2
    return 1
  fi
  local esc_dotted="${token//./\\.}"
  local esc_dashed="${token//./-}"
  local pattern="([^A-Za-z0-9_]${esc_dotted}([^A-Za-z0-9_.]|\$)|--alp-token-${esc_dashed}([^A-Za-z0-9_-]|\$))"
  rg -c "$pattern" \
    --type-add 'alptoken:*.{ts,tsx,css}' --type alptoken \
    --glob '!**/theme-*.ts' \
    --glob '!**/raw-tokens.ts' \
    --glob '!**/semantic-tokens.tsx' \
    --glob '!**/transform.ts' \
    --glob '!**/transform.test.ts' \
    --glob '!scripts/alpaca-semantic-tokens-playground/**' \
    --glob '!**/*.test.*' \
    --glob '!**/*.stories.*' \
    | awk -F: 'BEGIN{t=0} {t+=$NF; print} END{print "---\ntotal:", t}'
}

setup_codespace() {
    target_dir=".olexpono"

    # ensure we are in git repo
    git rev-parse --is-inside-work-tree &> /dev/null || { echo "Not in a git repo"; exit 1; }

    # if target_dir exists, print and exit
    if [ -d "$target_dir" ]; then
      echo "[$target_dir] - ready!"
      exit 0
    fi

    echo "$target_dir" >> .git/info/exclude
    echo "obsidian.code-workspace.json" >> .git/info/exclude

    echo '{"folders":[{"name":"scratch","path":".olexpono"},{"name":"obsidian","path":"."}]}' >> obsidian.code-workspace.json
    mkdir -p "$target_dir"

    echo "Created $target_dir and added to .git/info/exclude"
}

ensure_olexpono_excluded() {
  [[ "$PWD" == "/workspaces/obsidian" ]] || return 0
  git rev-parse --is-inside-work-tree &> /dev/null || return 0

  local exclude_file
  exclude_file="$(git rev-parse --git-dir)/info/exclude"
  grep -qxF ".olexpono" "$exclude_file" 2>/dev/null || echo ".olexpono" >> "$exclude_file"
}
ensure_olexpono_excluded

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
# alias gb="git for-each-ref --format='%(refname:short) %(worktreepath)' refs/heads"
gb() {
  emulate -L zsh
  local -A wt_fg=(
    teal    23
    blue    17
    magenta 53
    orange  94
    lime    22
    purple  54
  )
  local default_fg=147

  git rev-parse --is-inside-work-tree &>/dev/null || { echo "gb2: not a git repo" >&2; return 1 }

  # branch -> worktree path, for branches checked out in some worktree
  local -A active_wt
  local branch wtpath
  while IFS='|' read -r branch wtpath; do
    [[ -z "$wtpath" ]] && continue
    active_wt[$branch]=$wtpath
  done < <(git for-each-ref --format='%(refname:short)|%(worktreepath)' refs/heads)

  for branch in "${(@ko)active_wt}"; do
    wtpath=${active_wt[$branch]}
    local fg=$default_fg name=""
    for name in teal blue magenta orange lime purple; do
      if [[ $wtpath == *$name* ]]; then
        fg=${wt_fg[$name]}
        break
      fi
    done
    printf -- '-> %s  \e[38;5;%sm%s\e[0m\n' "$branch" "$fg" "$wtpath"
  done

  # latest branches checked out (any worktree, any time on this machine),
  # excluding branches currently active in a worktree, newest first, max 8
  local -a wt_paths
  wt_paths=("${(@f)$(git worktree list --porcelain | awk '/^worktree /{print substr($0,10)}')}")

  local count=0
  local -A seen
  while IFS=' ' read -r _ branch; do
    [[ -z "$branch" ]] && continue
    [[ -n ${active_wt[$branch]} ]] && continue
    [[ -n ${seen[$branch]} ]] && continue
    git show-ref --verify --quiet "refs/heads/$branch" || continue
    seen[$branch]=1
    printf -- '   %s\n' "$branch"
    (( ++count >= 8 )) && break
  done < <(
    for wtpath in "${wt_paths[@]}"; do
      git -C "$wtpath" reflog show --date=unix HEAD 2>/dev/null
    done |
      sed -n 's/^[^ ]* HEAD@{\([0-9]*\)}: checkout: moving from .* to \(.*\)$/\1 \2/p' |
      sort -rn
  )
}

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
echo -e "  Call '${yellow}ops${reset}' to list shorthand commands\n"

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

worktree() {
  local name="${1:?usage: worktree <worktree-name> [branch-name] [args...]}"
  shift || return 1

  local branch="${1:-}"
  if [ -n "$branch" ]; then
    echo "Error: branch name is required" >&2
    shift || return 1
  else
    printf "Branch name: " >&2
    IFS= read -r branch || return 1
    [ -n "$branch" ] || {
      echo "Branch name is required" >&2
      return 1
    }
  fi

  local repo_root repo_parent worktree_path
  repo_root="$(git -C /workspaces/obsidian rev-parse --show-toplevel)" || return 1
  repo_parent="$(dirname "$repo_root")"

  worktree_path="$(
      git -C "$repo_root" worktree list --porcelain |
        awk -v branch="refs/heads/$branch" '
          /^worktree / { path = substr($0, 10) }
          /^branch / && $2 == branch { print path; exit }
        '
    )" || return 1

  if [ -n "$worktree_path" ]; then
    echo "$branch worktree already exists at $worktree_path"
  else
    worktree_path="$repo_parent/$name"
    if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
      git -C "$repo_root" worktree add "$worktree_path" "$branch"
    else
      git -C "$repo_root" worktree add -b "$branch" "$worktree_path" HEAD
    fi
  fi
}

alpaca-token-files() {
  local sourcejson="scripts/alpaca-semantic-tokens-playground/src/token-data-verbose.json"
  if [ -n "$sourcejson" ]; then
    jq -r --arg t "$1" '.files[$t][]' scripts/alpaca-semantic-tokens-playground/src/token-data-verbose.json
  else
    echo "No token data file found at $sourcejson ~ are you in an obsidian root?"
  fi
}
