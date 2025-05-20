_: {
  programs = {
    bat = {
      enable = true;
      config = {
        theme = "Monokai Extended Origin";
        pager = "less -FR";
      };
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
