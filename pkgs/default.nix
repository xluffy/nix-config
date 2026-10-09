# Custom packages.
# Built via 'nix build .#<name>' or accessed as pkgs.<name> in home-manager
# via the overlay in ../overlays
{
  pkgs,
  pkgsUnstable ? pkgs,
  isDarwin ? pkgs.stdenv.hostPlatform.isDarwin,
}:
{
  kage = pkgs.callPackage ./kage.nix {
    go = pkgsUnstable.go_1_26;
  };

  kcctl = pkgs.callPackage ./kcctl.nix {};

  yomi = pkgs.callPackage ./yomi.nix {
    go = pkgsUnstable.go_1_26;
  };
}
// (
  if isDarwin
  then {
    commander-one = pkgs.callPackage ./commander-one.nix {};
    flux-markdown = pkgs.callPackage ./flux-markdown.nix {};
    oh-my-token = pkgs.callPackage ./oh-my-token.nix {};
  }
  else {}
)
