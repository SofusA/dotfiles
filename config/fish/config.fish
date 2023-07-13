alias upgrade 'sudo dnf upgrade -y; flatpak upgrade -y; distrobox upgrade -a'
alias ls 'exa -1 --color=always --group-directories-first'

set -gx EDITOR hx
set -U fish_greeting
