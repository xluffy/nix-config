{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    pkgs-unstable.betterdisplay
    pkgs-unstable.karabiner-elements
    pkgs-unstable.telegram-desktop
  ];
}
