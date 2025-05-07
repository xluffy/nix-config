_: {
  programs = {
    bat = {
      enable = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fzf = { enable = true; };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
