{
  description = "My development flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.flatpak-xdg-utils.url = "path:./tools/flatpak-xdg-utils";
  inputs.ccase.url = "path:./tools/ccase";
  inputs.angular-language-server.url = "github:sofusa/angular-language-server/main";
  inputs.roslyn-language-server.url = "github:sofusa/roslyn-language-server/main";
  inputs.helix.url = "github:sofusa/helix-pull-diagnostics/pull-diagnostics";
  inputs.jujutsu.url = "github:martinvonz/jj";
  inputs.zellij.url = "github:a-kenji/zellij-nix";
  inputs.bicep.url = "github:sofusa/bicep-language-server-nix";
  inputs.azure-pipelines.url = "github:sofusa/azure-pipelines-language-server-nix";

  outputs = { 
    self, 
    nixpkgs,
    nixpkgs-unstable,
    flake-utils,
    flatpak-xdg-utils,
    ccase,
    angular-language-server,
    roslyn-language-server,
    helix,
    jujutsu,
    zellij,
    bicep,
    azure-pipelines
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        pkgs-unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
      in
      {

        packages.dotnetSdks = pkgs.buildEnv {
          name = "dotnetSdks";
          paths = [
            (with pkgs.dotnetCorePackages;
            combinePackages [
              dotnet_8.sdk
              dotnet_8.aspnetcore
              sdk_6_0_1xx
            ])
          ];
        };

        devShell = pkgs.mkShell {
          buildInputs = [
            # helix
            helix.packages.${system}.helix
            pkgs.nil
            pkgs.taplo
            pkgs.tailwindcss-language-server
            pkgs.typescript
            pkgs.nodePackages.typescript-language-server
            pkgs.vscode-langservers-extracted
            pkgs.nodePackages.prettier
            angular-language-server.packages.${system}.angular-language-server
            roslyn-language-server.packages.${system}.roslyn-language-server
            pkgs.typos-lsp

            # shell
            pkgs.fish
            pkgs.starship
            pkgs.zoxide
            pkgs.atuin
            pkgs.fd
            ccase.packages.${system}.ccase
            flatpak-xdg-utils.packages.${system}.flatpak-xdg-utils
            pkgs.skim
            pkgs.wl-clipboard
            pkgs.sd
            pkgs.ripgrep
            zellij.packages.${system}.default
            pkgs.yaml-language-server

            # git
            pkgs.gitui
            pkgs.gh
            jujutsu.packages.${system}.jujutsu
            pkgs-unstable.lazyjj

            # dotnet
            self.packages.${system}.dotnetSdks
            pkgs.csharpier
            pkgs.azure-functions-core-tools

            # azure
            pkgs.azure-cli
            pkgs.powershell
            bicep.packages.${system}.bicep-langserver
            azure-pipelines.packages.${system}.azure-pipelines-language-server

            # rust
            pkgs.rustup
            pkgs.openssl
            pkgs.cargo-watch
            pkgs.leptosfmt

            # node
            pkgs.nodePackages.npm
            pkgs.nodePackages.yarn
            pkgs.nodePackages.nodejs

            # vscode
            pkgs.vscode

            # Chrome
            pkgs.google-chrome
            pkgs.chromedriver

            # Playwright
            pkgs.playwright-driver.browsers
          ];


          shellHook =
            ''
              playwright_chromium_revision="$(${pkgs.jq}/bin/jq --raw-output '.browsers[] | select(.name == "chromium").revision' ${pkgs.playwright-driver}/browsers.json)"
              export PLAYWRIGHT_LAUNCH_OPTIONS_EXECUTABLE_PATH="${pkgs.playwright-driver.browsers}/chromium-$playwright_chromium_revision/chrome-linux/chrome";
              export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=rue;
              export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig";          

              source ~/.env
              zellij
            '';
        };
      }
    );
}
