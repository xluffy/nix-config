{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    _1password-gui
    pkgs-unstable.betterdisplay
    pkgs-unstable.karabiner-elements
    pkgs-unstable.telegram-desktop
  ];
}
