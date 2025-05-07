_: {

  programs = {
    git = {
      enable = true;

      userEmail = "quang@2meo.com";
      userName = "xluffy";

      aliases = {
        a = "add";
        p = "push";
        ci = "commit";
        st = "status -uno";
        stt = "status";
        co = "checkout";
        br = "branch";
        lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
        lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
      };

      extraConfig = {
        color = {
          branch = "auto";
          diff = "auto";
          status = "auto";
        };

        commit = {
          gpgSign = true;
        };

        branch = {
          sort = "-committerdate";
        };

        init = {
          defaultBranch = "main";
        };

        gpg = {
          format = "ssh";
          ssh = {
            defaultKeyCommand = "sh -c 'echo key::$(ssh-add -L | head -n1)'";
          };
        };

        push = {
          default = "current";
        };

        pull = {
          rebase = false;
        };

        tag = {
          gpgSign = true;
        };

        url = {
          "git@github.com:" = {
            insteadOf = "https://github.com";
          };
          "ssh://git@github.com" = {
            insteadOf = "https://github.com";
          };
        };
      };

      diff-so-fancy = {
        enable = true;
      };
    };
  };
}
