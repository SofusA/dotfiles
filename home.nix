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
    gitui
    ripgrep

    vscode-langservers-extracted
    dotnet-sdk_7
    csharp-ls
    omnisharp-roslyn

    taplo # toml lsp
    nil # nix lsp

    nodePackages.prettier
    nodePackages.typescript-language-server
    nodejs_20
    gitAndTools.gh
    vscode

    wl-clipboard
    wofi
    waybar
    autotiling-rs

    azure-cli
    powershell

    google-chrome
  ];

  home.stateVersion = "23.05";
 
  programs.home-manager.enable = true;
}
