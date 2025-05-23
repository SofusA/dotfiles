{
  description = "My development flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.fenix.url = "github:nix-community/fenix";

  inputs.ccase.url = "github:rutrum/ccase";
  inputs.angular-language-server.url = "github:sofusa/angular-language-server";
  inputs.csharp-language-server.url = "github:sofusa/csharp-language-server";
  inputs.helix.url = "github:sofusa/helix-pull-diagnostics/pull-diagnostics";
  inputs.bicep.url = "github:sofusa/bicep-language-server-nix";
  inputs.azure-pipelines.url = "github:sofusa/azure-pipelines-language-server-nix";
  inputs.qobuz-player.url = "github:sofusa/qobuz-player-nix";

  outputs = { 
    self, 
    nixpkgs,
    nixpkgs-stable,
    flake-utils,
    fenix,
    ccase,
    angular-language-server,
    csharp-language-server,
    helix,
    bicep,
    azure-pipelines,
    qobuz-player
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        pkgs-stable = import nixpkgs-stable { inherit system; config.allowUnfree = true; };
      in
      {

        packages.dotnetSdks = pkgs.buildEnv {
          name = "dotnetSdks";
          paths = [
            (with pkgs-stable.dotnetCorePackages;
            combinePackages [
              dotnet_9.sdk
              dotnet_9.aspnetcore
              dotnet_8.sdk
              dotnet_8.aspnetcore
            ])
          ];
        };

        devShell = pkgs.mkShell {
          buildInputs = [
            # helix
            helix.packages.${system}.helix
            pkgs.nil
            pkgs.taplo
            pkgs.tailwindcss-language-server
            pkgs.typescript
            pkgs.nodePackages.typescript-language-server
            pkgs.vscode-langservers-extracted
            pkgs.nodePackages.prettier
            angular-language-server.packages.${system}.angular-language-server
            csharp-language-server.packages.${system}.csharp-language-server
            pkgs.typos-lsp
            pkgs.svelte-language-server
            pkgs.rustywind
            pkgs.lemminx
            pkgs.markdown-oxide

            # shell
            pkgs.fish
            pkgs.nushell
            pkgs.carapace
            pkgs.starship
            pkgs.zoxide
            pkgs.atuin
            pkgs.fd
            ccase.packages.${system}.default
            pkgs.skim
            pkgs.wl-clipboard
            pkgs.sd
            pkgs.ripgrep
            pkgs.yaml-language-server
            pkgs.eza
            pkgs.zellij
            pkgs.yazi
            pkgs.see-cat
            pkgs.uutils-coreutils-noprefix
            pkgs.rpg-cli

            qobuz-player.packages.${system}.qobuz-player

            # git
            pkgs.gitui
            pkgs.gh
            pkgs.jujutsu
            pkgs.lazyjj
            pkgs.meld

            # dotnet
            self.packages.${system}.dotnetSdks
            pkgs-stable.csharpier
            pkgs.azure-functions-core-tools

            # azure
            pkgs-stable.azure-cli
            pkgs-stable.powershell
            bicep.packages.${system}.bicep-langserver
            azure-pipelines.packages.${system}.azure-pipelines-language-server

            # rust
            (fenix.packages.${system}.complete.withComponents [
              "cargo"
              "clippy"
              "rust-src"
              "rustc"
              "rustfmt"
            ])
            fenix.packages.${system}.rust-analyzer
            pkgs.openssl
            pkgs.cargo-watch
            pkgs.cargo-machete
            pkgs.leptosfmt

            # javascript
            pkgs.nodePackages.npm
            pkgs.nodePackages.yarn
            pkgs.nodePackages.nodejs
            pkgs.deno
            pkgs.live-server

            # vscode
            pkgs.vscode

            # Chrome
            pkgs.google-chrome
            pkgs.chromedriver

            # Playwright
            pkgs.playwright-driver.browsers

            # Niri
            pkgs.xwayland-satellite
            pkgs.bore-cli
          ];

          shellHook =
            ''
              export PLAYWRIGHT_BROWSERS_PATH="${pkgs.playwright-driver.browsers}"
              export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true;

              export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig";          
              export DOTNET_ROOT="${pkgs-stable.dotnetCorePackages.dotnet_9.sdk}";

              export EDITOR=hx

              source ~/.env
              zellij
            '';
        };
      }
    );
}
