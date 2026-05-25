{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.shell.promptColor;
in {
  options.custom.shell.promptColor = {
    primary = lib.mkOption {
      type = lib.types.str;
      default = "32"; # green
      description = "ANSI color code for the prompt primary parts (e.g. ::, $, and working directory bracket).";
    };
    host = lib.mkOption {
      type = lib.types.str;
      default = "34"; # blue
      description = "ANSI color code for the hostname.";
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "38;5;46"; # bright green
      description = "ANSI color code for the username.";
    };
  };

  config = {
    programs = {
      bash = {
        enable = true;
        enableCompletion = false;

        shellAliases = {
          awk = "goawk";
          bcat = "bat";
          cd = "z";
          ca = "cursor-agent";
          cc = "claude";
          cx = "codex";
          gg = "agy";
          df = "df -h | tail -n 8 | sort";
          du = "du -sch";
          grep = "grep --color=auto";
          j = "just";
          k = "kubectl";
          ls = "ls --color=auto -larth";
          l = "ls";
          ll = "ls";
          lll = "ls";
          more = "less";
          p = "curl https://ipinfo.io/ip";
          ping = "ping -c 5";
          pong = "ping google.com.vn";
          pv = "pv -pert";
          r = "openssl rand -base64 15";
          rg = "rg --hidden --glob '!.git'";
          ssh-keygen = "ssh-keygen -o -a 100 -t ed25519 -b 4096";
          vim = "nvim";
        };

        # empty mean unlimit
        historySize = 999999999;
        historyFileSize = 999999999;
        historyFile = "${config.home.homeDirectory}/.bash_history";

        historyControl = [
          "ignoredups"
        ];

        shellOptions = ["histappend"];

        sessionVariables = {
          BASH_SILENCE_DEPRECATION_WARNING = 1;
          GO111MODULE = "on";
          HISTTIMEFORMAT = "[%F %T] ";
          USE_GKE_GCLOUD_AUTH_PLUGIN = 1;
          CLOUDSDK_PYTHON_SITEPACKAGES = 1;
          EDITOR = "nvim";
        };

        initExtra = ''
          source ${config.home.homeDirectory}/.config/nix-config/function.sh
          source <(helm completion bash)
          source <(kubectl completion bash)
          PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
        '';

        bashrcExtra = ''
          export PATH="$HOME/.nix-profile/bin:$HOME/bin:~/.npm-packages/bin:$HOME/.local/bin:$PATH"
          export NODE_PATH=~/.npm-packages/lib/node_modules
          PS1='\[\e[0;${cfg.primary}m\]:: \[\e[0;37m\]You are \[$(tput bold)\]\[\033[${cfg.user}m\]\u\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]-at- \[\e[0;${cfg.host}m\]\h\[\e[0;37m\] [\[\e[0;${cfg.primary}m\]\w\[\e[0;39m\]]\n\[\e[0;${cfg.primary}m\]\$\[\e[m\] '

          shuf -n 1 ${config.home.homeDirectory}/.config/nix-config/quote.txt | cowsay

          bind '"\e[A": history-search-backward'
          bind '"\e[B": history-search-forward'

          if [[ -z BASH_COMPLETION_VERSINFO ]]; then
            . "${pkgs.bash-completion}/etc/profile.d/bash_completion.sh"
          fi
        '';
      };
    };
  };
}
