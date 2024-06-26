{
  description = "My development flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.flatpak-xdg-utils.url = "path:./tools/flatpak-xdg-utils";
  inputs.ccase.url = "path:./tools/ccase";

  inputs.language-servers.url = "path:./tools/ngserver";
  inputs.language-servers.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, flake-utils, flatpak-xdg-utils, ccase, language-servers}:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true;};
      in {

        packages.dotnetSdks = pkgs.buildEnv {
          name = "dotnetSdks";
          paths = [
            (with pkgs.dotnetCorePackages;
              combinePackages [
                dotnet_8.sdk
                dotnet_8.aspnetcore
                sdk_6_0_1xx
              ])
          ];
        };

      
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            # helix
            helix
            nil
            taplo
            omnisharp-roslyn
            tailwindcss-language-server
            nodePackages.typescript-language-server
            vscode-langservers-extracted
            nodePackages.prettier
            
            # shell
            fish
            starship
            zoxide
            atuin
            fd
            ccase.packages.${system}.ccase
            flatpak-xdg-utils.packages.${system}.flatpak-xdg-utils
            skim
            wl-clipboard
            ripgrep

            # git
            gitui
            gh

            # dotnet
            self.packages.${system}.dotnetSdks
            csharpier

            # angular
            language-servers.packages.angular-language-server

            # azure
            azure-cli
            powershell

            # rust
            rustup
            openssl
            cargo-watch

            # node
            nodePackages.npm
            nodePackages.yarn
            nodePackages.nodejs

            # vscode
            vscode

            # Chrome
            google-chrome
            chromedriver
          ];

          shellHook = 
          ''
            export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig";
            fish
          '';
        };
      }
    );
}
