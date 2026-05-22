{
  pkgs,
  pkgs-unstable,
  ...
}: let
  myPhp = pkgs.php84.withExtensions ({
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
    pkgs.php84Packages.composer
    pkgs.phpactor
    pkgs-unstable.frankenphp
  ];
}
