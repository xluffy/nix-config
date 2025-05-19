{ pkgs, pkgs-unstable, ... }:
{

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    pkgs-unstable.hackgen-nf-font
    pkgs-unstable.nerd-fonts._0xproto
    pkgs-unstable.nerd-fonts.jetbrains-mono
    pkgs-unstable.nerd-font-patcher
    pkgs-unstable.noto-fonts
  ];
}
