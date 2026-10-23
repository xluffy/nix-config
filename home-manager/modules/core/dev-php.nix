{
  pkgs,
  pkgs-unstable,
  ...
}: let
  myPhp = pkgs.php85.withExtensions ({
    all,
    enabled,
  }:
    enabled
    ++ [
      all.redis
    ]);
in {
  home.packages = [
    myPhp
    pkgs.php85Packages.composer
    pkgs.phpactor
    pkgs-unstable.frankenphp
  ];
}
