{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  hostname,
  ip,
  ...
}: let
  interface = "ztklh2jwcc";
  network = "6ab565387ac1e038";
in {
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

  networking.firewall.trustedInterfaces = [interface];

  networking.extraHosts = ''
    10.144.0.1 walt-desktop
    10.144.0.2 walt-phone
    10.144.0.3 walt-laptop
    10.144.0.4 walt-cloud
    10.144.0.5 walt-vr
    10.144.0.6 walt-reader
  '';

  services.zerotierone = {
    enable = true;
    joinNetworks = [network];

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
          "127.0.0.1"
          "127.0.0.2"
        ];
      };
    };
  };

  # nginx will initially fail to start if zerotier isn't running since it cannot bind to the ip address yet.
  systemd.services.nginx = {
    bindsTo = ["sys-devices-virtual-net-${interface}.device"];
    after = ["sys-devices-virtual-net-${interface}.device"];
  };
}
