{pkgs, ...}: {
  environment.systemPackages = [pkgs.irssi pkgs.polari];

  services.telepathy.enable = true;

  home-manager.sharedModules = [
    {
      programs.irssi = {
        enable = true;

        aliases = {
          znc = "msg *status";
        };

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
            chatnet = "libera-znc";
            address = "walt-cloud";
            port = "5000";
            use_ssl = "no";
            ssl_verify = "no";
            autoconnect = "yes";
            password = "waltmck/libera:password";
          },
          {
            chatnet = "oftc-znc";
            address = "walt-cloud";
            port = "5000";
            use_ssl = "no";
            ssl_verify = "no";
            autoconnect = "yes";
            password = "waltmck/oftc:password";
          }
          );

          chatnets = {
            "libera-znc" = { type = "IRC"; };
            "oftc-znc" = { type = "IRC"; };
          };
        '';
      };
    }
  ];

  # services.weechat.enable = true;
}
