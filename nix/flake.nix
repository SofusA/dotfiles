{
  description = "My development flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.flatpak-xdg-utils.url ="path:./tools/flatpak-xdg-utils";
  inputs.ccase.url ="path:./tools/ccase";

  outputs = { self, nixpkgs, flake-utils, flatpak-xdg-utils, ccase}:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true;};
      in {
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
            dotnetCorePackages.dotnet_8.sdk
            dotnetCorePackages.dotnet_8.aspnetcore

            # azure
            azure-cli
            powershell

            # rust
            rustup
            openssl
            cargo-watch

            # node
            nodePackages.npm
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
