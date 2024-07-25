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
      settings.General.EnableNetworkConfiguration = true;
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

  # Use CloudFlare's DNS. Needed because wifi DNS was
  # broken for a Riad Dar Naai in Marrakech.
  
  environment.etc."resolv.conf".text = ''
    nameserver 1.1.1.1
  '';
  

  environment.persistence."/nix/state".directories = [
    "/var/lib/iwd"
    "/etc/NetworkManager/system-connections"
  ];
}
