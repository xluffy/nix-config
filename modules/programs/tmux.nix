_: {

  programs.tmux = {
    enable = true;

    prefix = "C-a";
    baseIndex = 1;
    clock24 = true;
    escapeTime = 1;
    historyLimit = 999999999;
    keyMode = "vi";
    terminal = "screen-256color";
    mouse = false;

    extraConfig = ''
      set -ga terminal-overrides ",xterm-256color:Tc"

      setw -g pane-base-index 1

      # auto rename windows
      setw -g automatic-rename on

      # send prefix twice to other app (vim, bash)
      bind C-a send-prefix

      # split panes with current pwd
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # movement keys
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # cycle windows
      bind -r C-h select-window -t :-
      bind -r C-l select-window -t :+

      # resize pane and repeatable with -r option
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # handle mouse
      #setw -g mode-mouse on
      #set -g mouse-select-pane on
      #set -g mouse-resize-pane on
      #set -g mouse-select-window on

      # change status bar color
      set -g status-style fg=white,bg=colour234

      # windows status color
      setw -g window-status-style fg=colour244,bg=default,dim

      # windows active status color
      setw -g window-status-current-style fg=colour166,bg=default,bright

      # pane color
      set -g pane-border-style fg=yellow,bg=black
      set -g pane-active-border-style fg=colour39,bg=default

      # msg color command
      set -g message-style fg=colour166,bg=colour235,bright

      # status bar left
      set -g status-left-length 40
      set -g status-left "#[fg=brightwhite,bg=brightblack] #S #[fg=default,bg=default] "

      # status bar right
      set -g status-right 'Battery: #{battery_icon} #{battery_percentage} #[fg=cyan]»» #[fg=magenta]%T | %a | %d-%m-%y #[default]'
      set -g status-right-length 150

      # status keep update inerval
      set -g status-interval 10

      # vi mode
      setw -g mode-keys vi
      set -g status-keys vi

      # terminal emulator window title
      set -g set-titles on
      set -g set-titles-string '#h ❐ #S ● #I #W'

      # window status
      set -g window-status-format "#[fg=white,bg=brightblack] #I #[fg=white,bg=#363636] |#(despell #W) #W#F "
      set -g window-status-current-format "#[fg=brightwhite,bg=green] #I #[fg=brightwhite,bg=blue] #(despell #W) #W#F "
      set -g window-status-separator " "
      set -g status-justify left

      # clock
      setw -g clock-mode-colour green

      # broadcast all panes
      bind u setw synchronize-panes
      set-environment -g 'SSH_AUTH_SOCK' ~/.ssh/ssh_auth_sock

      # config tmux-yank
      set-option -g default-command "reattach-to-user-namespace -l $SHELL"

    '';
  };
  environment.systemPackages = with pkgs; [
    tmuxPlugins.sensible
    tmuxPlugins.resurrect
    tmuxPlugins.yank
    tmuxPlugins.battery
    tmuxPlugins.cpu
  ];
}
