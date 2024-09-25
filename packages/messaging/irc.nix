{pkgs, ...}: {
  environment.systemPackages = [pkgs.irssi];

  home-manager.sharedModules = [
    {
      programs.irssi = {
        enable = true;

        /*
        networks.znc = {
          nick = "waltmck";
          server = {
            address = "walt-cloud";
            port = 5000;
            ssl.verify = false;
            ssl.enable = true;
          };
        };
        */

        extraConfig = ''
          servers = (
          {
            chatnet = "znc";
            address = "walt-cloud";
            port = "5000";
            use_ssl = "no";
            ssl_verify = "no";
            autoconnect = "yes";
            username = "waltmck";
            password = "password";
          }
          );
        '';
      };
    }
  ];

  # services.weechat.enable = true;
}
