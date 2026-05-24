_: {
  imports = [
    ./modules/core
    ./modules/programs
    ./modules/shell
  ];

  home = {
    username = "quang.van.nguyen";
    homeDirectory = "/Users/quang.van.nguyen";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
