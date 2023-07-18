{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.username = "sofusa";
  home.homeDirectory = "/home/sofusa";

  home.packages = with pkgs; [                               
    fish
    helix
    exa
    joshuto
    vscode-langservers-extracted
    exa
    dotnet-sdk_7
    csharp-ls

    nodePackages.prettier
    nodePackages.typescript-language-server
    nodejs_20
    gitui
    gitAndTools.gh
    vscode

    taplo # toml lsp
    nil # nix lsp

    wofi
    waybar

    azure-cli
    powershell

    google-chrome
  ];

  home.stateVersion = "23.05";
 
  programs.home-manager.enable = true;
}
