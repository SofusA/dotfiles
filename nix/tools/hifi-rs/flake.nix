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
            url = "https://github.com/iamdb/hifi.rs/releases/download/v0.3.8/hifi-rs-x86_64-unknown-linux-gnu.tar.gz";
            sha256 = "sha256-91kVziYsX/9voLE26QJpIuukDGHz5nC+o4S4B/jEiBo=";
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


#  # {
#   inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
#   inputs.flake-utils.url = "github:numtide/flake-utils";

#   outputs = { self, nixpkgs, flake-utils }:
#     flake-utils.lib.eachDefaultSystem (system:
#       let
#         pkgs = nixpkgs.legacyPackages.${system};
#       in
#       {
#         packages.hifi-rs= pkgs.rustPlatform.buildRustPackage {
#           pname = "hifi-rs";
#           version = "0.3.8";

#           buildInputs = [ pkgs.pkg-config ];
#           src = pkgs.fetchFromGitHub {
#             owner = "iamdb";
#             repo = "hifi.rs";
#             rev = "main";
#             hash = "sha256-96V2gDevpg6PZzzQsNB9l99VKcV27YmxHzp5jaXilcU=";
#           };

#           cargoHash = "sha256-n2EZrxSJ6mMX0EFWnWv0gIC8s3T1xe1nCwdojijlEdk=";

#         };
#         # packages.hifi-rs = pkgs.stdenv.mkDerivation {
#         #   pname = "hifi-rs";
#         #   version = "0.3.8";

#         #   src = pkgs.fetchFromGitHub {
#         #     owner = "iamdb";
#         #     repo = "hifi.rs";
#         #     rev = "main";
#         #     sha256 = "sha256-96V2gDevpg6PZzzQsNB9l99VKcV27YmxHzp5jaXilcU=";
#         #   };

#         #   buildInputs = [ pkgs.cargo ];

#         #   # configurePhase = ''
#         #   #   rustup default stable
#         #   # '';

#         #   installPhase = ''
#         #     cargo build --bin=hifi-rs
#         #   '';
#         # };
#       }
#     );
# }
