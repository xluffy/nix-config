_: {
  imports = [
    ./modules/core
    ./modules/programs
    ./modules/shell
  ];

  home = {
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
