#!/usr/bin/env bash
# Redistribute files from repo to their correct locations
# e.g. after git pull
set -euo pipefail

# nvim config: mirror repo -> ~/.config/nvim
# --delete removes files in dest that no longer exist in repo (kills stale/nested cruft)
rsync -a --delete ~/dotfiles/nvim/ ~/.config/nvim/
# exclude plugins/ so --delete cannot wipe TPM-installed plugins (repo has no plugins)
rsync -a --delete --exclude 'plugins/' ~/dotfiles/tmux/ ~/.config/tmux/

# bootstrap TPM on a fresh machine, then plugins install via prefix+I
if [ ! -f ~/.config/tmux/plugins/tpm/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
    echo "TPM installed. In tmux: reload config, then press prefix+I to install plugins."
fi

# bash dotfiles: copy only if present in repo
[ -f ~/dotfiles/.bashrc ] && cp ~/dotfiles/.bashrc ~/.bashrc
[ -f ~/dotfiles/.bash_aliases ] && cp ~/dotfiles/.bash_aliases ~/.bash_aliases
