_: {
  home.file = {
    ".config/1Password/ssh/agent.toml".text = ''
      # You can test the result by running:
      #
      #  SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ssh-add -l
      #
      # More examples can be found here:
      #  https://developer.1password.com/docs/ssh/agent/config
      [[ssh-keys]]
      vault = "Private"
      item = "ozvndytabt4gd7maq22nj3ekwa"
    '';
  };
}
