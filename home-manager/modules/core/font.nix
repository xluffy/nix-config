{ pkgs, pkgs-unstable, ... }:
{

  home.packages = with pkgs; [
    pkgs-unstable.nerd-fonts.jetbrains-mono
    pkgs-unstable.hackgen-nf-font
    pkgs-unstable.nerd-font-patcher
  ];
}
