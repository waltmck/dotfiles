{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  hostname,
  ...
}: {
  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "0.0.0.0:8081";
      BASE_URL = "http://walt-cloud/rss/";
    };

    adminCredentialsFile = pkgs.writeText "miniflux-cred" ''
      ADMIN_USERNAME=waltmck
      ADMIN_PASSWORD=password
    '';
  };

  # Set up a Nginx virtual host.
  services.nginx = {
    enable = true;
    virtualHosts."${hostname}" = {
      locations."/rss" = {
        proxyPass = "http://127.0.0.1:8081";
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

  services.postgresql = {
    dataDir = "/data/config/postgresql/15";
    package = pkgs.postgresql_15;
  };
}
