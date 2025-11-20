#!/bin/bash

sudo chsh "$(id -un)" --shell "/usr/bin/zsh"

mkdir ".olexpono"
echo ".olexpono" >> .git/info/exclude

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

setup_codespace() {
    target_dir=".olexpono"

    # ensure we are in git repo
    git rev-parse --is-inside-work-tree &> /dev/null || { echo "Not in a git repo"; exit 1; }

    # if target_dir exists, print and exit
    if [ -d "$target_dir" ]; then
      echo "$target_dir already exists, nothing to do"
      exit 0
    fi

    echo "$target_dir" >> .git/info/exclude
    echo "obsidian.code-workspace.json" >> .git/info/exclude

    echo '{"folders":[{"name":"scratch","path":".olexpono"},{"name":"obsidian","path":"."}]}' >> obsidian.code-workspace.json
    mkdir -p "$target_dir"

    echo "Created $target_dir and added to .git/info/exclude"
}

create_symlinks
setup_codespace

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions.git ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
