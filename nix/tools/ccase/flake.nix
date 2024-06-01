{
  description = "A simple Nix flake to install ccase";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.ccase= with nixpkgs.legacyPackages.x86_64-linux; 
      rustPlatform.buildRustPackage {
        pname = "ccase";
        version = "0.4.1";

          src = pkgs.fetchFromGitHub {
            owner = "rutrum";
            repo = "ccase";
            rev = "7ca56557d0cc69641e0d0c5ae9370c48f4cce09d";
            hash = "sha256-TQJkvANms/5Mzh1J4qsEYOrlML17dVv7MYEoN4Z/gm0=";
          };

        cargoHash = "sha256-TAjKBUzyJUtSwj3EkD0+/owEWrmxws58axS2YMlG0MY=";
      };
  };
}
