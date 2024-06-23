{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  hostname,
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

    virtualHosts = {
      "cloud.waltmckelvie.com" = {
        enableACME = true;
        forceSSL = true;

        locations = {
          "/stream/" = {
            proxyPass = "http://127.0.0.1:8096/";
          };
        };
      };

      # Intranet
      "${hostname}" = {
        # Listen for all traffic
        listenAddresses = [
          "0.0.0.0"
          "[::]"
        ];

        locations = {
          "/headscale-metrics/" = {
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
