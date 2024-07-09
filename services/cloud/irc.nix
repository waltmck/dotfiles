{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  hostname,
  ...
}: {
  services.soju = {
    enable = true;
    hostName = "http://walt-cloud";

    /*
      extraConfig = ''
      db sqlite3 /data/config/soju/main.db
      message-store fs /data/config/soju/logs/
    '';
    */
  };

  # See https://hacdias.com/2023/12/24/irc-bouncer-setup-soju-gamja-caddy-docker/

  systemd.services.soju = let
    configFile = pkgs.writeText "soju.conf" ''
      listen irc+insecure://0.0.0.0:6667
      listen ws+insecure://0.0.0.0:3030
      listen unix+admin:///run/soju/admin
      hostname walt-cloud.com

      db sqlite3 /data/config/soju/soju.db
      log fs /data/config/soju/logs
      http-origin
      accept-proxy-ip
    '';
  in {
    serviceConfig = {
      environment = ''
        ADMIN=waltmck
        PASSWORD=password
      '';

      ExecStart = lib.mkOverride 10 "${pkgs.soju}/bin/soju -config ${configFile}";
    };
  };

  # Set up a Nginx virtual host.
  services.nginx = {
    enable = true;
    virtualHosts."${hostname}" = {
      locations."/irc" = {
        proxyPass = "http://127.0.0.1:6667";
        extraConfig = ''
          proxy_redirect off;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
      locations."/soju" = {
        proxyPass = "http://127.0.0.1:3030";
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
}
