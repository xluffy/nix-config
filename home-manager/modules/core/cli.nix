{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    coreutils
    cowsay
    curl
    diff-so-fancy
    direnv
    eza
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
    reattach-to-user-namespace
    ripgrep
    tig
    tmux
    wget
    yq
    zoxide
  ];
}
