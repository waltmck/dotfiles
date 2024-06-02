{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  ...
}: {
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "sysadmin@waltmckelvie.com";

    certs = {
      "cloud.waltmckelvie.com" = {};
      "headscale.waltmckelvie.com" = {};
    };
  };

  services.nginx = {
    enable = true;

    virtualHosts = let
      auth_snippet = ''
        auth_request /auth;
        auth_request_set $auth_user $upstream_http_tailscale_user;
        auth_request_set $auth_name $upstream_http_tailscale_name;
        auth_request_set $auth_login $upstream_http_tailscale_login;
        auth_request_set $auth_tailnet $upstream_http_tailscale_tailnet;
        auth_request_set $auth_profile_picture $upstream_http_tailscale_profile_picture;

        proxy_set_header X-Webauth-User "$auth_user";
        proxy_set_header X-Webauth-Name "$auth_name";
        proxy_set_header X-Webauth-Login "$auth_login";
        proxy_set_header X-Webauth-Tailnet "$auth_tailnet";
        proxy_set_header X-Webauth-Profile-Picture "$auth_profile_picture";
      '';
    in {
      "cloud.waltmckelvie.com" = {
        enableACME = true;
        forceSSL = true;

        locations = {
          # See https://github.com/tailscale/tailscale/tree/main/cmd/nginx-auth for documentation
          "/auth" = {
            extraConfig = ''
              internal;
              proxy_pass_request_body off;
              proxy_set_header Host $host;
              proxy_set_header Remote-Addr $remote_addr;
              proxy_set_header Remote-Port $remote_port;
              proxy_set_header Original-URI $request_uri;
              proxy_set_header Expected-Tailnet "headscale.waltmckelvie.com";
            '';

            proxyPass = "http://unix:/run/tailscale-nginx-auth/tailscale-nginx-auth.sock";
          };
          "/admin/" = {
            # extraConfig = auth_snippet;

            proxyPass = "http://127.0.0.1:9090/";
          };
        };
      };

      "headscale.waltmckelvie.com" = {
        enableACME = true;
        forceSSL = true;

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:8080/";
            proxyWebsockets = true;

            extraConfig = ''
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection $connection_upgrade;
              proxy_set_header Host $server_name;
              proxy_redirect http:// https://;
              proxy_buffering off;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              add_header Strict-Transport-Security "max-age=15552000; includeSubDomains" always;
            '';
          };
        };
      };
    };
  };

  # Allow nginx to access the tailscaleAuth socket
  systemd.services.nginx.serviceConfig.ProtectHome = false;
  users.groups."tailscale-nginx-auth".members = ["nginx"];

  services.tailscaleAuth = {
    enable = true;
    socketPath = "/run/tailscale-nginx-auth/tailscale-nginx-auth.sock";
  };

  # Persist SSL certificates
  environment.persistence."/nix/state" = {
    directories = [
      {
        directory = "/var/lib/acme";
        user = "acme";
        group = "acme";
        mode = "0755";
      }
    ];
  };
}
