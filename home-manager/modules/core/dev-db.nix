{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    pkgs-unstable.libpq
    pkgs-unstable.mariadb_1011
    postgresql_17
    redis
  ];
}
