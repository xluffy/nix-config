{ pkgs, ... }:

{
  imports = [
    ./modules/core/cli.nix
    ./modules/programs/git.nix
    ./modules/programs/default.nix
    ./modules/shell/bash.nix
  ];

  home = {
    username = "quanggg";
    homeDirectory = "/Users/quanggg";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}
