{ config, pkgs, ... }:

{
  home.username = "sofusa";
  home.homeDirectory = "/home/sofusa";

  home.packages = [                               
    pkgs.fish
    pkgs.helix
    pkgs.exa
    pkgs.vscode-langservers-extracted
    pkgs.exa
    pkgs.dotnet-sdk_7
    pkgs.omnisharp-roslyn
    pkgs.nodePackages.prettier
    pkgs.nodejs_20
    pkgs.gitui
  ];

  home.stateVersion = "23.05";
 
  programs.home-manager.enable = true;
}
