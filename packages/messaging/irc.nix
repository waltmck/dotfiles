{pkgs, ...}: {
  # Polari is broken for now, see https://github.com/NixOS/nixpkgs/issues/149685

  environment.systemPackages = [
    pkgs.irssi
    # pkgs.polari
  ];

  # services.telepathy.enable = true;

  home-manager.sharedModules = [
    {
      programs.irssi = {
        enable = true;

        aliases = {
          znc = "msg *status";
        };

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

          ignores = ( { level = "JOINS PARTS QUITS"; } );
        '';
      };

      xdg.desktopEntries = {
        irssi = let
          icon = "preferences-desktop-display";
          tagline = "Terminal-based IRC client";
        in {
          name = "Irssi";
          genericName = "Terminal-based IRC client";
          exec = ''${pkgs.kitty}/bin/kitty --name "Irssi" --class "${icon}" -- ${pkgs.irssi}/bin/irssi'';
          terminal = false;
          categories = ["Application" "Network" "Chat"];
          icon = "${icon}-symbolic";
          comment = tagline;
        };
      };
    }
  ];

  # services.weechat.enable = true;
}
