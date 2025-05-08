{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    bun
    go
    gnumake
    gcc
    postgresql
    pkgs-unstable.libpq
  ];
}
