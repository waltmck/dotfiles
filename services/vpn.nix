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

  networking.extraHosts = ''
    10.144.0.1 walt-desktop
    10.144.0.2 walt-phone
    10.144.0.3 walt-laptop
  '';

  services.zerotierone = {
    enable = true;
    joinNetworks = ["6ab565387ac1e038"];

    localConf = {
      settings = {
        primaryPort = 9993;
      };
    };
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
        # Restrict to zerotier
        /*
        extraConfig = ''
          allow 10.144.0.0/16;
          allow 127.0.0.0/8;
          allow ::1/128;
          deny  all;
        '';
        */

        # Listen for traffic from zerotier
        listenAddresses = [
          "${ip}"
        ];
      };
    };
  };
}
