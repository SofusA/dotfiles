set -gx EDITOR kak
alias python python3
alias upgrade 'sudo dnf upgrade -y; flatpak upgrade -y'
alias upgradesb 'rpm-ostree upgrade; flatpak upgrade -y'
alias vpn 'sudo openconnect --protocol=gp gpgatewayhbk.bksv.com -u saddington'

