{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.username = "sofusa";
  home.homeDirectory = "/home/sofusa";

  home.packages = with pkgs; [                               
    fish
    helix
    exa
    vscode-langservers-extracted
    exa
    dotnet-sdk_7
    omnisharp-roslyn
    nodePackages.prettier
    nodejs_20
    gitui
    gitAndTools.gh
    vscode
    foot
  ];

  home.stateVersion = "23.05";
 
  programs.home-manager.enable = true;
}
