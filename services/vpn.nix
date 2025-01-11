{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  hostname,
  ...
}: {
  /*
  environment.systemPackages = [pkgs.tailscale];

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall = {
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
    checkReversePath = "loose";
  };

  environment.persistence."/nix/state" = {
    directories = [
      {
        directory = "/var/lib/tailscale";
        mode = "0700";
      }
    ];
  };

  networking.hosts = {
    "127.0.0.1" = [hostname];
  };
  */

  services.zerotierone = {
    enable = true;
    joinNetworks = ["6ab565387ac1e038"];
  };

  environment.persistence."/nix/state" = {
    directories = [
      {
        directory = "/var/lib/zerotier-one";
        mode = "0700";
      }
    ];
  };

  services.nginx = {
    enable = true;

    virtualHosts = {
      # Intranet
      "${hostname}" = {
        # Restrict to tailscale
        extraConfig = ''
          allow 100.64.0.0/24;
          allow 127.0.0.0/8;
          allow ::1/128;
          deny  all;
        '';

        # Listen for all traffic
        listenAddresses = [
          "0.0.0.0"
          "[::]"
        ];
      };
    };
  };
}
