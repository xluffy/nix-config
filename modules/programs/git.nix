_: {

  programs = {
    git = {
      enable = true;

      userEmail = "quang@2meo.com";
      userName = "xluffy";

      signing = {
        key = "B54B9C74B03CAAD3";
      };

      aliases = {
        a = "add";
        p = "push";
        ci = "commit";
        st = "status -uno";
        co = "checkout";
        br = "branch";
        lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
        lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
      };

      extraConfig = {
        branch = {
          sort = "-committerdate";
        };
        push = {
          default = "current";
        };
        pull = {
          rebase = false;
        };
        init = {
          defaultBranch = "main";
        };
        gpg = {
          format = "ssh";
        };
        commit = {
          gpgSign = true;
        };
        tag = {
          gpgSign = true;
        };
        url."ssh://git@github.com".insteadOf = "https://github.com";
      };

      diff-so-fancy = {
        enable = true;
      };
    };
  };
}
