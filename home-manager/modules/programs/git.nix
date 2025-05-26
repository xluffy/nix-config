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
            # "${pkgs._1password-gui}/bin/op-ssh-sign";
            program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
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

        user = {
          signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII6gzw6c40c8zowzZ6nR8iRwsYy0qg2sNvro09nFtTzF";
        };
      };

      diff-so-fancy = {
        enable = true;
      };

      ignores = [
        ".DS_Store"
        ".env"
        "__pycache__"
        ".terraform"
        "terraform.tfvars"
        "*.key"
        "*.pem"
        "*.crt"
        ".vault_*"
      ];
    };
  };
}
