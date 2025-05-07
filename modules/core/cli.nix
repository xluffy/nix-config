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
    goawk
    htop
    jq
    just
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
    zoxide
  ];
}
