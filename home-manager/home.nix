_: {
  imports = [
    ./modules/core/cli.nix
    ./modules/core/dev.nix
    ./modules/core/font.nix
    ./modules/core/gui.nix
    ./modules/core/nix.nix
    ./modules/programs/1password.nix
    ./modules/programs/default.nix
    ./modules/programs/fzf.nix
    ./modules/programs/git.nix
    ./modules/programs/ssh.nix
    ./modules/programs/tmux.nix
    ./modules/shell/bash.nix
  ];

  home = {
    username = "quanggg";
    homeDirectory = "/Users/quanggg";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
