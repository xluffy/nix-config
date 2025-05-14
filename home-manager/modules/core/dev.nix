{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    pkgs-unstable.bun
    go
    gnumake
    gcc
    postgresql
    pkgs-unstable.libpq
    rustc
    rustup
  ];
}
