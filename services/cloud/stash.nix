{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  hostname,
  ip,
  ...
}: {
  systemd.services.stash = {
    description = "Stash";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      User = "data";
      Group = "data";
      ExecStart = ''
        ${pkgs.zsh}/bin/zsh -lc "${pkgs.stash}/bin/stash --nobrowser --config /data/config/stash/config.yml"
      '';
      Restart = "on-failure";
    };
  };

  services.nginx = let
    stashConfig = ''
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "Upgrade";
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Port $server_port;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Prefix /stash;
      proxy_read_timeout 60000s;
    '';
  in {
    virtualHosts."${hostname}".locations."/stash/" = {
      proxyPass = "http://127.0.0.1:9999/";

      extraConfig = stashConfig;
    };
  };

  programs.virt-manager.enable = true;
  virtualisation = {
    docker = {
      enable = true;
    };
    libvirtd.enable = true;
  };

  virtualisation.oci-containers.containers = {
    stash-vr-companion = {
      image = "ghcr.io/tweeticoats/stash-vr-companion:latest";
      ports = ["127.0.0.1:5000:5000"];

      environment = {
        API_URL = "http://${ip}:9999/graphql";
      };

      extraOptions = [
        "--pull=always"
        "--network=host"
        "--dns=100.100.100.100"
      ];
    };
  };

  systemd.services.podman-stash-vr-companion.after = ["network-online.target"];
}
