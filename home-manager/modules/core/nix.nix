{ pkgs, ... }:

{
  home.packages = with pkgs; [
    deadnix
    nix-tree
    nixfmt-rfc-style
    statix
  ];
}
