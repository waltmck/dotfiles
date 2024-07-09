{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  hostname,
  ...
}: {
  # Need to enable write access in order for push notifications to work, i.e. `ntfy access '*' 'up*' write-only`

  # In order to create user: `sudo ntfy user add --role=admin waltmck`
  services.ntfy-sh = {
    enable = true;

    settings = {
      base-url = "https://ntfy.waltmckelvie.com";

      auth-file = "/data/config/ntfy/user.db";
      cache-file = "/data/config/ntfy/cache-file.db";
      attachment-cache-dir = "/data/config/ntfy/attachments";

      enable-login = true;
      behind-proxy = true;
      auth-default-access = "deny-all";
      listen-http = "0.0.0.0:2586";

      # Make Matrix work
      visitor-request-limit-exempt-hosts = "176.126.240.158";
    };
  };
  systemd.services.ntfy-sh = {
    serviceConfig = {
      BindPaths = ["/data/config/ntfy"];
    };
  };

  security.acme.certs."ntfy.waltmckelvie.com" = {};

  # Set up a Nginx virtual host.
  services.nginx = {
    enable = true;
    virtualHosts."ntfy.waltmckelvie.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:2586";
        priority = 0;
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_redirect off;

          proxy_set_header Host $host;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

          proxy_connect_timeout 3m;
          proxy_send_timeout 3m;
          proxy_read_timeout 3m;

          client_max_body_size 0; # Stream request body to backend
        '';
      };

      locations."/mollysocket/" = {
        proxyPass = "http://127.0.0.1:8020/";
        priority = 1; # This should be before `location /`
      };
    };
  };

  # Signal notifications with mollysocket

  services.mollysocket = {
    enable = true;

    settings = {
      host = "127.0.0.1";
      port = 8020;
      allowed_endpoints = [
        "https://ntfy.waltmckelvie.com"
      ];
      webserver = true;

      db = "/data/config/mollysocket/mollysocket.db";
    };
  };

  systemd.services.mollysocket = {
    serviceConfig = {
      BindPaths = ["/data/config/mollysocket"];
    };
  };
}
