{
  pkgs,
  pkgs-unstable,
  hasGUI ? true,
  ...
}: {
  home.packages = pkgs.lib.optionals hasGUI (with pkgs;
    [
      _1password-gui
      pkgs-unstable.tailscale
    ]
    ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [
      pkgs-unstable.betterdisplay
      pkgs-unstable.karabiner-elements
    ]));
}
