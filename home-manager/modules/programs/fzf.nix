_: {
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
    defaultOptions = [
      "--height 90%"
      "--border"
    ];
  };
}
