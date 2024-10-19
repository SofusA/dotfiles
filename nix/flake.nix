{
  description = "My development flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
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
          buildInputs = with pkgs; [
            # helix
            helix.packages.${system}.helix
            nil
            taplo
            tailwindcss-language-server
            typescript
            nodePackages.typescript-language-server
            vscode-langservers-extracted
            nodePackages.prettier
            angular-language-server.packages.${system}.angular-language-server
            roslyn-language-server.packages.${system}.roslyn-language-server
            typos-lsp

            # shell
            fish
            starship
            zoxide
            atuin
            fd
            ccase.packages.${system}.ccase
            flatpak-xdg-utils.packages.${system}.flatpak-xdg-utils
            skim
            wl-clipboard
            sd
            ripgrep
            zellij.packages.${system}.default
            yaml-language-server

            # git
            gitui
            gh
            jujutsu.packages.${system}.jujutsu

            # dotnet
            self.packages.${system}.dotnetSdks
            csharpier
            azure-functions-core-tools

            # azure
            azure-cli
            powershell
            bicep.packages.${system}.bicep-langserver
            azure-pipelines.packages.${system}.azure-pipelines-language-server

            # rust
            rustup
            openssl
            cargo-watch
            leptosfmt

            # node
            nodePackages.npm
            nodePackages.yarn
            nodePackages.nodejs

            # vscode
            vscode

            # Chrome
            google-chrome
            chromedriver

            # Playwright
            playwright-driver.browsers

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
