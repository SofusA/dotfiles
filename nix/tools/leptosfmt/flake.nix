{
  description = "Leptosfmt";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.leptosfmt = pkgs.stdenv.mkDerivation {
          pname = "leptosfmt";
          version = "0.1.30";

          src = pkgs.fetchurl {
            url = "https://github.com/bram209/leptosfmt/releases/download/0.1.30/leptosfmt-0.1.30-x86_64-unknown-linux-musl.tar.gz";
            sha256 = "sha256-Qa7jHc25osqzl4NgxM1F0dCaoSNY5kW6GuQD4jBzC4g=";
          };

          sourceRoot = ".";
          nativeBuildInputs = [ pkgs.makeWrapper ];

          installPhase = ''
            mkdir -p $out/bin
            cp leptosfmt $out/bin/
            wrapProgram $out/bin/leptosfmt --set PATH $out/bin
          '';
        };
      }
    );

}
