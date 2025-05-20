{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    pkgs-unstable.bun
    go
    gnumake
    gcc
    postgresql
    python313
    pkgs-unstable.libpq
    rustc
    rustup
  ];
}
