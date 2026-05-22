{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    php
    php84Extensions.bcmath
    php84Extensions.ctype
    php84Extensions.curl
    php84Extensions.dom
    php84Extensions.fileinfo
    php84Extensions.filter
    php84Extensions.mbstring
    php84Extensions.opcache
    php84Extensions.readline
    php84Extensions.redis
    php84Extensions.zip
    php84Extensions.xml
    php84Packages.composer
    phpactor
    pkgs-unstable.frankenphp
  ];
}
