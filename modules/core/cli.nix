{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    coreutils
    cowsay
    curl
    diff-so-fancy
    direnv
    fzf
    gnumake
    gnupg
    htop
    jq
    kubectl
    kubectx
    ncdu
    neovim
    pv
    ripgrep
    tig
    tmux
    wget
    yq
  ];
}
