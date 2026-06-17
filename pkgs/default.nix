# Custom packages, built via 'nix build .#kage'
# Also accessible as pkgs.kage in home-manager via the overlay in ../overlays
{
  pkgs,
  pkgsUnstable ? pkgs,
}: {
  # kage needs go >= 1.26.4; unstable has 1.26.3 (closest match).
  # Falls back to pkgs.go_1_25 when pkgsUnstable is not provided.
  kage = pkgs.callPackage ./kage.nix {
    go =
      pkgsUnstable.go_1_26 or pkgs.go_1_25;
  };
}
