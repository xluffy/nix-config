{ pkgs, ... }:

{
  home.packages = with pkgs; [
    _1password-gui
    betterdisplay
    karabiner-elements
    microsoft-edge
  ];
}
