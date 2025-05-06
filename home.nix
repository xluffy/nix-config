{ pkgs, ... }:
{
  imports = [
    ./modules/core/cli.nix
  ];

  home = {
    username = "quanggg";
    homeDirectory = "/Users/quanggg";
    stateVersion = "24.11";
  };

  # Enable home-manager
  programs.home-manager.enable = true;
}
