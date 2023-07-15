alias upgrade 'home-manager -f ~/dotfiles/home.nix switch && ~/dotfiles/replace_config'
alias ls 'exa -1 --color=always --group-directories-first'
alias hxg 'nix run github:helix-editor/helix'

set -gx EDITOR hx
set -U fish_greeting

set PATH /var/home/sofusa/.npm-packages/bin $PATH
