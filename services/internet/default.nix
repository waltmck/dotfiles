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
  networking.nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];

  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = ["~."];
    fallbackDns = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
    # dnsovertls = "true"; # This breaks connecting to harvard.edu on Harvard wifi.
  };

  environment.persistence."/nix/state".directories = [
    "/var/lib/iwd"
    "/etc/NetworkManager/system-connections"
  ];
}
