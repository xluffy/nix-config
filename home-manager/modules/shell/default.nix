{...}: {
  imports = [
    ./bash.nix
  ];

  home.file = {
    ".config/nix-config/function.sh".source = ./function.sh;
    ".config/nix-config/quote.txt".source = ./quote.txt;
    ".config/nix-config/commit-prompt.txt".source = ./commit-prompt.txt;
    ".inputrc".source = ./inputrc;
    ".npmrc".source = ../../config/.npmrc;
  };
}
