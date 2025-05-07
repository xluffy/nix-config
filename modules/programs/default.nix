{ pkgs, self, ... }:

{
  programs = {
    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
