{
  description = "A simple derivation for the flatpak-xdg-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.flatpak-xdg-utils = pkgs.stdenv.mkDerivation {
          pname = "flatpak-xdg-utils";
          version = "unstable-2024-05-31";

          src = pkgs.fetchFromGitHub {
            owner = "flatpak";
            repo = "flatpak-xdg-utils";
            rev = "master";
            sha256 = "sha256-etsrkVpRdvGxipa9TQ5cSvTYviIJBkSpjQJaMeuAtXc=";
          };

          buildInputs = [ pkgs.meson pkgs.ninja pkgs.pkg-config pkgs.cmake pkgs.glib ];

          configurePhase = ''
            meson build
          '';

          buildPhase = ''
            ninja -C build
          '';

          installPhase = ''
            install -D build/src/flatpak-spawn $out/bin/flatpak-spawn
          '';
        };
      }
    );
}
