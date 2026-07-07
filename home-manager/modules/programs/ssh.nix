{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.ssh;
  identityAgentLine =
    if pkgs.stdenv.isDarwin
    then "IdentityAgent ~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else "";
in {
  options.custom.ssh = {
    identityFile = lib.mkOption {
      type = lib.types.str;
      default =
        if pkgs.stdenv.isDarwin
        then "~/.ssh/ssh-ed25519:quang@2meo.com.pub"
        else "~/.ssh/id_ed25519";
      description = "Path to SSH private/public key for GitHub.";
    };
  };

  config = {
    # Client side SSH configuratio
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*".Compression = true;
    };

    home.file.".ssh/config".text = ''
      Host github.com
        User xluffy
        IdentityFile ${cfg.identityFile}
        ${identityAgentLine}

      Host 172.20.0.21
        ${identityAgentLine}

      Host * !127.0.0.1
        ForwardAgent no
        AddKeysToAgent no
        Compression yes
        ServerAliveInterval 0
        ServerAliveCountMax 3
        HashKnownHosts no
        UserKnownHostsFile ~/.ssh/known_hosts
        ControlMaster no
        ControlPath ~/.ssh/master-%r@%n:%p
        ControlPersist no
        Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-gcm@openssh.com,aes128-ctr
        KexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512
        MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com
        RequiredRSASize 3072
        HostKeyAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256
        CASignatureAlgorithms sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256
        HostbasedAcceptedAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256
        PubkeyAcceptedAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256
        ${identityAgentLine}
    '';
  };
}
