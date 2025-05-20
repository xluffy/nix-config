{ pkgs, ... }:

{
  home.packages = with pkgs; [
    _1password-cli
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
    kubernetes-helm
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
