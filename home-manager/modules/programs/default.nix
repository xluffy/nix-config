_: {
  programs = {
    bat = {
      enable = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    eza = {
      enable = true;
      enableBashIntegration = true;
    };
    fzf = { enable = true; };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
