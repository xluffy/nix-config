{ pkgs, ... }: {

  programs = {
    bash = {
      enable = true;
      enableCompletion = false;

      shellAliases = {
        awk = "goawk";
        bcat = "bat";
        cd = "z";
        date = "gdate '+%A, %B %d, %Y [%T]";
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
        ssh-keygen = "ssh-keygen -o -a 100 -t ed25519 -b 4096";
        vim = "nvim";
      };

      # empty mean unlimit
      historySize = 999999999;
      historyFileSize = 999999999;
      historyFile = "~/.bash_unlimit_history";

      historyControl = [
        "ignoredups"
      ];

      shellOptions = [ "histappend" ];

      sessionVariables = {
        BASH_SILENCE_DEPRECATION_WARNING = 1;
        GO111MODULE = "on";
        HISTTIMEFORMAT = "[%F %T] ";
        USE_GKE_GCLOUD_AUTH_PLUGIN = 1;
        CLOUDSDK_PYTHON_SITEPACKAGES = 1;
        EDITOR = "nvim";
      };

      initExtra = ''
        eval "$(direnv hook bash) "
        source ~/code/me/nix-config/home-manager/modules/shell/function.sh
      '';

      bashrcExtra = ''
        PS1='\[\e[0;32m\]:: \[\e[0;37m\]Youuuuuuuuuuuu are \[$(tput bold)\]\[\033[38;5;46m\]\u\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]-at- \[\e[0;34m\]\h\[\e[0;37m\] [\[\e[0;32m\]\w\[\e[0;39m\]]\n\[\e[0;32m\]\$\[\e[m\] '

        gshuf -n 1 ~/code/me/nix-config/home-manager/modules/shell/quote.txt | cowsay

        bind '"\e[A": history-search-backward'
        bind '"\e[B": history-search-forward'

        if [[ -z BASH_COMPLETION_VERSINFO ]]; then
          . "${pkgs.bash-completion}/etc/profile.d/bash_completion.sh"
        fi
      '';
    };
  };
}
