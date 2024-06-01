{
  description = "A simple derivation for the flatpak-xdg-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.flatpak-xdg-utils = with nixpkgs.legacyPackages.x86_64-linux; stdenv.mkDerivation {
      pname = "flatpak-xdg-utils";
      version = "unstable-2024-05-31";

      src = fetchgit {
        url = "https://github.com/flatpak/flatpak-xdg-utils";
        rev = "b24e62ea9b342797ebd203ef3dc7aa0dc02d45a8";
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
