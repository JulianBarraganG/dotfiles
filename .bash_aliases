alias oldvim='/usr/bin/vim'
alias vim='nvim'
alias dots='bash ~/dotfiles/update.sh'
alias vnv='source .venv/bin/activate'
alias lnv='set -a && source .env && set +a'
alias supp='sudo apt update && sudo apt upgrade -y'
alias bat='batcat'
# git
alias gst='git status'
# estate
alias estate='cd ~/projects/bls-estate-products/ && mise prep'
alias upcd='cd ~/projects/bls-estate-products/ && task up && task p:clinical:up'
alias downcd='cd ~/projects/bls-estate-products/ && task down && task p:clinical:down'
alias restack='downcd && pm2 delete all && upcd'
