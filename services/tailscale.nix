{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  hostname,
  ...
}: {
  environment.systemPackages = [pkgs.tailscale];

  services.tailscale = {
    enable = true;
    openFirewall = true;

    # These appear to be broken, you still need to do them manually
    extraUpFlags = [
      "--login-server=https://headscale.waltmckelvie.com"
      "--operator=waltmck"
    ];
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
