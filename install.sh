#!/bin/bash

sudo chsh "$(id -un)" --shell "/usr/bin/zsh"

if ! command -v nvim &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y neovim
fi

create_symlinks() {
    # Get the directory in which this script lives.
    script_dir=$(dirname "$(readlink -f "$0")")

    # Get a list of all files in this directory that start with a dot.
    files=$(find -maxdepth 1 -type f -name ".*")

    # Create a symbolic link to each file in the home directory.
    for file in $files; do
        name=$(basename $file)
        echo "Creating symlink to $name in home directory."
        rm -rf ~/$name
        ln -s $script_dir/$name ~/$name
    done
}

create_symlinks

link_agents_md() {
    script_dir=$(dirname "$(readlink -f "$0")")

    rm -rf ~/AGENTS.md
    ln -s "$script_dir/AGENTS.md" ~/AGENTS.md

    mkdir -p ~/.claude
    rm -rf ~/.claude/CLAUDE.md
    ln -s "$script_dir/AGENTS.md" ~/.claude/CLAUDE.md
}

link_agents_md

link_skills() {
    local script_dir skill_dir skill_name agent_skills_dir skill_link
    script_dir=$(dirname "$(readlink -f "$0")")

    mkdir -p "$HOME/.codex/skills" "$HOME/.claude/skills"

    for skill_dir in "$script_dir"/skills/*; do
        [ -d "$skill_dir" ] || continue

        skill_name=$(basename "$skill_dir")
        for agent_skills_dir in "$HOME/.codex/skills" "$HOME/.claude/skills"; do
            skill_link="$agent_skills_dir/$skill_name"
            if [ -e "$skill_link" ] && [ ! -L "$skill_link" ]; then
                echo "Skipping $skill_link because it is not a symlink."
                continue
            fi
            ln -sfn "$skill_dir" "$skill_link"
        done
    done
}

link_skills

link_nvim() {
    script_dir=$(dirname "$(readlink -f "$0")")

    mkdir -p ~/.config
    rm -rf ~/.config/nvim
    ln -s "$script_dir/.config/nvim" ~/.config/nvim
}

link_nvim

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions.git ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
