{
  description = "ccase";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let 
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.ccase = pkgs.rustPlatform.buildRustPackage {
          pname = "ccase";
          version = "0.4.1";

          src = pkgs.fetchFromGitHub {
            owner = "rutrum";
            repo = "ccase";
            rev = "master";
            hash = "sha256-TQJkvANms/5Mzh1J4qsEYOrlML17dVv7MYEoN4Z/gm0=";
          };

          cargoHash = "sha256-TAjKBUzyJUtSwj3EkD0+/owEWrmxws58axS2YMlG0MY=";
        };
      }
    );
}
