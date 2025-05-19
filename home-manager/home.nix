{ pkgs, ... }:

{
  imports = [
    ./modules/core/cli.nix
    ./modules/core/dev.nix
    ./modules/core/font.nix
    ./modules/programs/default.nix
    ./modules/programs/fzf.nix
    ./modules/programs/git.nix
    ./modules/programs/ssh.nix
    ./modules/programs/tmux.nix
    ./modules/shell/bash.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "quanggg";
    homeDirectory = "/Users/quanggg";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}
