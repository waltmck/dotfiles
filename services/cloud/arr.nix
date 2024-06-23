{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  hostname,
  ...
}: {
  services.prowlarr = {
    enable = true;
  };

  services.sonarr = {
    enable = true;
    user = "data";
    group = "data";

    dataDir = "/data/config/sonarr";
  };

  services.radarr = {
    enable = true;
    user = "data";
    group = "data";

    dataDir = "/data/config/radarr";
  };

  services.lidarr = {
    enable = true;
    user = "data";
    group = "data";

    dataDir = "/data/config/lidarr";
  };

  services.readarr = {
    enable = true;
    user = "data";

    dataDir = "/data/config/readarr";
  };

  services.nginx = {
    enable = true;

    virtualHosts."${hostname}" = let
      extraConfig = ''
        proxy_set_header Host $host;

        # Comment this line out to make *arr apps think that all traffic
        # is coming from localhost, disabling required authentication.
        # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $http_connection;
      '';
    in {
      # Note: if setting up from scratch, you must initially connect without the reverse proxy and set the URL Base and Application URL settings
      # Precisely: set URL Base to "/radarr" and Application URL to "${hostname}/radarr". This can be repeated for the rest of them.
      locations."^~ /radarr" = {
        proxyPass = "http://127.0.0.1:7878";

        inherit extraConfig;
      };
      locations."^~ /radarr/api" = {
        proxyPass = "http://127.0.0.1:7878";
        extraConfig = "auth_basic off;";
      };

      locations."^~ /sonarr" = {
        proxyPass = "http://127.0.0.1:8989";

        inherit extraConfig;
      };
      locations."^~ /sonarr/api" = {
        proxyPass = "http://127.0.0.1:8989";
        extraConfig = "auth_basic off;";
      };

      locations."^~ /lidarr" = {
        proxyPass = "http://127.0.0.1:8686";

        inherit extraConfig;
      };
      locations."^~ /lidarr/api" = {
        proxyPass = "http://127.0.0.1:8686";
        extraConfig = "auth_basic off;";
      };

      locations."^~ /prowlarr" = {
        proxyPass = "http://127.0.0.1:9696";

        inherit extraConfig;
      };
      locations."^~ /prowlarr/api" = {
        proxyPass = "http://127.0.0.1:9696";
        extraConfig = "auth_basic off;";
      };

      locations."^~ /readarr" = {
        proxyPass = "http://127.0.0.1:8787";

        inherit extraConfig;
      };
      locations."^~ /readarr/api" = {
        proxyPass = "http://127.0.0.1:8787";
        extraConfig = "auth_basic off;";
      };
    };
  };
}
