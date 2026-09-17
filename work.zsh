DISABLE_AUTO_UPDATE=true
DISABLE_UPDATE_PROMPT=true
export GITHUB_USER="olexpono"

red=$'\e[0;31m'
red2=$'\e[0;35m'
yellow=$'\e[0;33m'
yellow2=$'\e[0;36m'
reset="\e[0m"
echo -e "\n  ${yellow}C O D E${reset}\n  ${red}S P A C E S${reset}\n${yellow}-${red}-${red2}-${yellow2}-${red2}-${red}-${yellow}-${red}-${red2}-${yellow2}-${red2}-${red}-${yellow}-${reset}"
echo -e "  Call '${yellow}ops${reset}' to list shorthand commands\n"

alias spp="git pull && just post-pull && just dev-replace-web"
alias wtests="just unit-test-project web-client"
alias wtc="just turbo typecheck -F @vanta/web-client"
alias static="npx turbo run project-static-analysis --concurrency=16 --log-order=stream --continue --summarize"
alias wlint="just turbo lint -F @vanta/web-client"
alias wlogs="just dev-watch-logs web"
alias webdev="just dev-start-web"
alias webz="just dev-web-staging"
alias sbook="just dev-storybook"

unalias alpstat 2>/dev/null
alpstat() {
  local pkg=@vanta/alpaca-static-analysis
  local root; root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
  local dir=$root/scripts/alpaca-static-analysis
  local site=$dir/site

  if [[ ! -d $site ]]; then
    print -u2 "alpstat: run from inside the teal checkout (no $site)"
    return 1
  fi

  [[ $1 == -r || $1 == --regen ]] && rm -f $site/public/*.json

  if [[ ! -x $dir/node_modules/.bin/tsx ]]; then
    print -u2 "alpstat: workspace deps missing — run 'just post-pull' first"
    return 1
  fi
  [[ -d $site/node_modules ]]           || pnpm --filter $pkg site:install || return 1
  [[ -f $site/public/components.json ]] || pnpm --filter $pkg generate     || return 1
  pnpm --filter $pkg serve
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

worktree() {
  local name="${1:?usage: worktree <worktree-name> [branch-name] [args...]}"
  shift || return 1

  local branch="${1:-}"
  if [ -n "$branch" ]; then
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

# The banner above advertises `ops`; list what this file actually defines.
ops() {
  print -P "\n%F{yellow}Shorthand commands%f (${DOTFILES_DIR:-~/dotfiles}/work.zsh)\n"
  awk '
    /^alias [a-zA-Z0-9_-]+=/ {
      split($0, a, "=")
      sub(/^alias /, "", a[1])
      cmd = $0
      sub(/^alias [a-zA-Z0-9_-]+=/, "", cmd)
      gsub(/^["'"'"']|["'"'"']$/, "", cmd)
      printf "  %-14s %s\n", a[1], cmd
      next
    }
    /^[a-zA-Z0-9_-]+\(\) \{/ {
      name = $1
      sub(/\(\).*/, "", name)
      printf "  %-14s (function)\n", name
    }
  ' "${DOTFILES_DIR:-$HOME/dotfiles}/work.zsh"
  print ""
}

alpaca-token-files() {
  local sourcejson="scripts/alpaca-semantic-tokens-playground/src/token-data-verbose.json"
  if [ -n "$sourcejson" ]; then
    jq -r --arg t "$1" '.files[$t][]' scripts/alpaca-semantic-tokens-playground/src/token-data-verbose.json
  else
    echo "No token data file found at $sourcejson ~ are you in an obsidian root?"
  fi
}
