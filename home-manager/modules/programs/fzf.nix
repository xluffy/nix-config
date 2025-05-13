_: {
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
    defaultOptions = [
      "--height 90%"
      "--border"
    ];
  };
}
