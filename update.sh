#!/bin/bash

# Add error handling
set -e

if [ ! -d ~/.config/nvim ]; then
    echo "Error: nvim config not found!"
    exit 1
fi

if [ ! -f ~/.bashrc ]; then
    echo "Error: .bashrc not found!"
    exit 1
fi

if [ ! -f ~/.bash_aliases ]; then
    echo "Error: .bash_aliases not found!"
    exit 1
fi

echo "Syncing dotfiles..."

cp -rf ~/.config/nvim/* ~/dotfiles/nvim/
cp ~/.bashrc ~/dotfiles/.bashrc
cp ~/.bash_aliases ~/dotfiles/.bash_aliases

# Clean up nvim directory
rm -rf ~/dotfiles/nvim/pack/ ~/dotfiles/nvim/.git/ ~/dotfiles/nvim/.gitignore

cd ~/dotfiles

git add --all
if git diff --staged --quiet; then
    echo "No changes to commit"
    exit 0
fi

git commit -m "Update dotfiles $(date)"
git push origin main
