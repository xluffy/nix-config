{
  programs = {
    bash = {
      enable = true;

      shellAliases = {
        awk = "goawk";
        bcat = "bat";
        cd = "z";
        date = "gdate '+%A, %B %d, %Y [%T]";
        df = "df -h | tail -n 8 | sort";
        du = "du -sch";
        k = "kubectl";
        l = "ls -larht";
        ll = "ls -larht";
        lll = "ls -larht";
        ls = "ls -larth";
        more = "less";
        p = "curl https://ipinfo.io/ip";
        ping = "ping -c 5";
        pong = "ping google.com.vn";
        pv = "pv -pert";
        r = "openssl rand -base64 15";
        ssh-keygen = "ssh-keygen -o -a 100 -t ed25519 -b 4096";
        vim = "nvim";
      };
    };
  };
}
