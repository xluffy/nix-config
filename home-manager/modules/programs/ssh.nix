_: {
  # Client side SSH configuratio
  programs.ssh = {
    enable = true;
    compression = true;
  };

  home.file.".ssh/config".source = ../../config/ssh_config;
}
