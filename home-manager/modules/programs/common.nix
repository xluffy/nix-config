_: {
  programs = {
    bat = {
      enable = true;
      config = {
        theme = "Monokai Extended Origin";
        pager = "less -FR";
      };
    };

    jq = {
      enable = true;
    };

    nix-index = {
      enable = true;
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
