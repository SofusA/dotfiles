set -gx EDITOR hx
set -U fish_greeting

alias upgrade 'sudo dnf upgrade -y; flatpak upgrade -y; distrobox upgrade -a'
