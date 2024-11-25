{
  description = "A flake to download, extract, and install hifi-rs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages = {
        hifi-rs = pkgs.stdenv.mkDerivation {
          name = "hifi-rs";
          src = pkgs.fetchurl {
            url = "https://github.com/sofusa/hifi.rs/releases/download/v4.5.4/hifi-rs-x86_64-unknown-linux-gnu.tar.gz";
            sha256 = "sha256-bd+9CL2JZlTAjO5K+GA9FERaiFcgmOqN4RI3LuS7C9Y=";
          };

          unpackPhase = ''
            tar xf $src
          '';

          installPhase = ''
            install -m755 -D hifi-rs $out/bin/hifi-rs
          '';
        };
      };
    }
  );
}
