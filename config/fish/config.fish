alias upgrade 'flatpak upgrade -y; home-manager -f ~/dotfiles/home.nix switch && ~/dotfiles/replace_config'
alias ls 'exa -1 --color=always --group-directories-first'

set -gx EDITOR hx
set -U fish_greeting
