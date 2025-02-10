{
  config,
  lib,
  pkgs,
  inputs,
  hostname,
  headless,
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
      settings.General.EnableNetworkConfiguration = false;
    };

    networkmanager = {
      enable = true;

      wifi.backend = "iwd";
    };
  };

  programs.nm-applet = {
    enable = !headless;
    indicator = true;
  };

  /*
  systemd.services.iwd = {
    bindsTo = ["sys-subsystem-net-devices-wlan0.device"];
    after = ["sys-subsystem-net-devices-wlan0.device"];
  };
  */

  environment.persistence."/nix/state".directories = [
    "/var/lib/iwd"
    "/etc/NetworkManager/system-connections"
  ];
}
