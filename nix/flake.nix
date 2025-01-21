{
  description = "My development flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.jujutsu.url = "github:bnjmnt4n/jj/ssh-openssh";

  # inputs.ccase.url = "path:./tools/ccase";
  inputs.angular-language-server.url = "github:sofusa/angular-language-server";
  inputs.roslyn-language-server.url = "github:sofusa/roslyn-language-server";
  inputs.helix.url = "github:sofusa/helix-pull-diagnostics/pull-diagnostics";
  inputs.bicep.url = "github:sofusa/bicep-language-server-nix";
  inputs.azure-pipelines.url = "github:sofusa/azure-pipelines-language-server-nix";
  # inputs.hifi-rs.url = "path:./tools/hifi-rs";

  outputs = { 
    self, 
    nixpkgs,
    nixpkgs-stable,
    flake-utils,
    # ccase,
    angular-language-server,
    roslyn-language-server,
    helix,
    bicep,
    azure-pipelines,
    jujutsu
    # hifi-rs
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
            roslyn-language-server.packages.${system}.roslyn-language-server
            pkgs.typos-lsp
            pkgs.svelte-language-server
            pkgs.rustywind
            pkgs.lemminx

            # shell
            pkgs.fish
            pkgs.nushell
            pkgs.carapace
            pkgs.starship
            pkgs.zoxide
            pkgs.atuin
            pkgs.fd
            # ccase.packages.${system}.ccase
            pkgs.skim
            pkgs.wl-clipboard
            pkgs.sd
            pkgs.ripgrep
            pkgs.yaml-language-server
            pkgs.eza
            pkgs.zellij
            pkgs.yazi

            # hifi-rs.packages.${system}.hifi-rs

            # git
            pkgs.gitui
            pkgs.gh
            jujutsu.packages.${system}.jujutsu
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
            pkgs.rustup
            pkgs.openssl
            pkgs.cargo-watch
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
            pkgs.waybar-mpris
          ];

          shellHook =
            ''
              export PLAYWRIGHT_BROWSERS_PATH="${pkgs.playwright-driver.browsers}"
              export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true;

              export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig";          
              export DOTNET_ROOT="${pkgs-stable.dotnetCorePackages.dotnet_8.sdk}";

              export EDITOR=hx

              source ~/.env
              zellij
            '';
        };
      }
    );
}
