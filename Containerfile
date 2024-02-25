FROM ghcr.io/greyltc-org/archlinux-aur:paru

RUN paru -Sy

# Container integration
RUN aur-install flatpak-xdg-utils wl-clipboard 

# Arch
RUN aur-install base base-devel openssh

# Rust
RUN aur-install rustup rust-analyzer cargo-watch

# Zip
RUN aur-install zip unzip 

# Git
RUN aur-install git github-cli gitui 

# Helix
RUN aur-install helix-git

# Cargo
RUN rustup default nightly
RUN cargo install cargo-binstall
RUN ~/.cargo/bin/cargo-binstall -y leptosfmt rustywind

# Dotnet develop
RUN aur-install aspnet-runtime aspnet-runtime-6.0 dotnet-sdk-6.0 omnisharp-roslyn powershell-bin azure-cli 

# Angular develop
RUN aur-install npm typescript-language-server vscode-langservers-extracted prettier visual-studio-code-bin google-chrome tailwindcss-language-server 

# Shell
RUN aur-install fish less skim fd ripgrep starship zoxide eza ccase 

RUN npm install -g @angular/cli @angular/language-service typescript @angular/language-server nx

RUN pacman -Scc --noconfirm

# Enable sudo permission for wheel users
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/t
