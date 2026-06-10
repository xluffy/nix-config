_: {
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      auto_sync = false;
      search_mode = "fuzzy";
      filter_mode = "global";
      enter_accept = true;
      style = "compact";
      inline_height = 20;
      update_check = false;
      show_help = false;
    };
  };
}
