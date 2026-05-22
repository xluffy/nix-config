{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    php
    php84Packages.composer
    php84Extensions.ctype
    php84Extensions.curl
    php84Extensions.dom
    php84Extensions.fileinfo
    php84Extensions.filter
    php84Extensions.mbstring
    phpactor
    pkgs-unstable.frankenphp
  ];
}
