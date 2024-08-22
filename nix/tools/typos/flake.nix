{
  description = "typos-lsp";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let 
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.typos = pkgs.rustPlatform.buildRustPackage {
          pname = "typos-lsp";
          version = "0.1.22";

          src = pkgs.fetchFromGitHub {
            owner = "tekumara";
            repo = "typos-lsp";
            rev = "main";
            hash = "sha256-AQCgZauygdE1lsCMiPrwVQoynOb+kzn9KzXSPMIumpM=";
          };

          cargoHash = "sha256-CG4q0dR7SImk2PX6BQLJaDmdt2Ru2VS6HXnUQQbIoVU=";
        };
      }
    );
}
