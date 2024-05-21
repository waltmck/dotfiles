{
  config,
  lib,
  pkgs,
  inputs,
  hostname,
  ...
}: {
  imports = [
    "${inputs.home-manager}/nixos"
    "${inputs.impermanence}/nixos.nix"
  ];

  networking = {
    hostName = hostname;
    wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = true;
    };

    networkmanager = {
      enable = true;

      wifi.backend = "iwd";
    };
  };

  environment.persistence."/nix/state".directories = [
    "/var/lib/iwd"
    "/etc/NetworkManager/system-connections"
  ];
}
