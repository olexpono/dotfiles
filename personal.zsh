# Personal shell config: general-purpose aliases/functions with no tie to a
# specific work repo. Safe to use on any machine (mac or linux) and in any
# git repo.
#
# NOT YET SOURCED from .zshrc — this is step one of splitting .zshrc's
# generic bits out of the shared file. See work.zsh for the work-only
# counterpart.

export BRANCH_PREFIX=olex

# ----- aliases -----
alias cl="claude --permission-mode=auto"
alias bop="python3 $DOTFILES_DIR/.local/bin/pr-status.py"

alias xcommit="git commit --no-gpg-sign"
alias branchpurge="git branch --merged | grep -v \"\*\" | xargs -n 1 git branch -d"
alias ack="noglob rg"
alias to="source ~/.zshrc"
alias tl="tmux list-sessions"
alias td="tmux detach"
alias gg="git status"

# ----- functions -----

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

# gb was an alias until 2026-09; zsh expands aliases at parse time, so
# re-sourcing into a shell that still has it fails without this unalias.
unalias gb 2>/dev/null
gb() {
  emulate -L zsh
  # Color names below (teal/blue/magenta/orange/lime/purple) match worktree
  # naming conventions from a specific work repo — harmless elsewhere, since
  # any path that doesn't match one just falls back to $default_fg.
  local -A wt_fg=(
    teal    23
    blue    17
    magenta 53
    orange  94
    lime    22
    purple  54
  )
  local default_fg=147

  git rev-parse --is-inside-work-tree &>/dev/null || { echo "gb: not a git repo" >&2; return 1 }

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
