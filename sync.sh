#!/usr/bin/env bash
# Redistribute files from repo to their correct locations
# e.g. after git pull
set -euo pipefail

# nvim config: mirror repo -> ~/.config/nvim
# --delete removes files in dest that no longer exist in repo (kills stale/nested cruft)
rsync -a --delete ~/dotfiles/nvim/ ~/.config/nvim/

# bash dotfiles: copy only if present in repo
[ -f ~/dotfiles/.bashrc ] && cp ~/dotfiles/.bashrc ~/.bashrc
[ -f ~/dotfiles/.bash_aliases ] && cp ~/dotfiles/.bash_aliases ~/.bash_aliases

echo "redist done"
