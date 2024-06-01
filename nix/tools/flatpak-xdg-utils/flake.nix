{
  description = "A simple derivation for the flatpak-xdg-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.flatpak-xdg-utils = with nixpkgs.legacyPackages.x86_64-linux; stdenv.mkDerivation {
      pname = "flatpak-xdg-utils";
      version = "unstable-2024-05-31";

      src = pkgs.fetchFromGitHub {
        owner = "flatpak";
        repo = "flatpak-xdg-utils";
        rev = "master";
        sha256 = "sha256-etsrkVpRdvGxipa9TQ5cSvTYviIJBkSpjQJaMeuAtXc=";
      };

      buildInputs = [ meson ninja pkg-config cmake glib ];

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
  };
}
