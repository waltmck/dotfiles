{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  hostname,
  ...
}: {
  services.znc = {
    enable = true;
    mutable = false;
    useLegacyConfig = false;
    openFirewall = false;

    dataDir = "/data/config/znc";

    config = let
      password = {
        Method = "sha256";
        Hash = "bff975916a91a4bf6eb11a05c338a056065e907a5299b3eff2f52fc2bafb6dc2";
        Salt = "kYQt85ztalhiQij7B2+_";
      };

      default = {
        AutoClearChanBuffer = false;
        Buffer = 500;
      };
    in {
      LoadModule = ["adminlog"];

      MaxBufferSize = 500;

      Listener.l = {
        Port = 5001;
        AllowWeb = false;
        AllowIRC = true;
        SSL = false;
      };

      User."waltmck" = {
        LoadModule = ["autoattach"];

        Admin = true;
        Nick = "waltmck";
        AltNick = "waltmckel";

        AutoClearChanBuffer = false;
        AutoClearQueryBuffer = false;
        ChanBufferSize = 500;

        Network.libera = {
          Server = "irc.libera.chat +6697";
          LoadModule = [
            "simple_away"
            "route_replies"
            "nickserv EreVMvde4QttCdB"
          ];

          Chan = {
            "#nixos" = default;
            "#openzfs" = default;
            "#zfsonlinux" = default;
            "#linux" = default;
            "#znc" = default;
            "#revolutionirc" = default;
            "#irssi" = default;
          };
        };

        Network.oftc = {
          Server = "irc.oftc.net +6697";
          LoadModule = [
            "simple_away"
            "route_replies"
            "nickserv EreVMvde4QttCdB"
          ];

          Chan = {
            "#asahi" = default;
            "#asahi-alt" = default;
            "#asahi-gpu" = default;
          };
        };

        Pass = {
          inherit password;
        };
      };
    };
  };
  /*
  services.nginx = {
    enable = true;
    virtualHosts."${hostname}" = {
      locations."/znc/" = {
        proxyPass = "http://127.0.0.1:5001/";
        extraConfig = ''
          proxy_redirect off;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };
  */
}
