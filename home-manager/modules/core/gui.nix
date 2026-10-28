{
  pkgs,
  pkgs-unstable,
  hasGUI ? true,
  ...
}: {
  home.packages = pkgs.lib.optionals hasGUI (with pkgs;
    [
      _1password-gui
      # draw.io CLI needs a display, so install the renderer on GUI hosts only.
      mermaid-drawio
      pkgs-unstable.tailscale
    ]
    ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [
      pkgs-unstable.betterdisplay
      commander-one
      pkgs-unstable.karabiner-elements
      flux-markdown
      oh-my-token
    ]));
}
