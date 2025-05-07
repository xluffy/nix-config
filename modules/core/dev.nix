{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gnumake
    gcc
    go
  ];
}
