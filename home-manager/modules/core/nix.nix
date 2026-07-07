{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    deadnix
    nix-tree
    nixfmt
    statix
  ];
}
