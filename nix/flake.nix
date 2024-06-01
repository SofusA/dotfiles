{
  description = "My development flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.flatpak-xdg-utils.url ="path:./tools/flatpak-xdg-utils";
  inputs.ccase.url ="path:./tools/ccase";

  outputs = { self, nixpkgs, flake-utils, flatpak-xdg-utils, ccase}:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            # helix
            helix
            nil
            taplo
            omnisharp-roslyn

            # shell
            fish
            starship
            zoxide
            atuin
            ccase.packages.${system}.ccase
            flatpak-xdg-utils.packages.${system}.flatpak-xdg-utils

            # git
            gitui

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
