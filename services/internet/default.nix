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

  # Use CloudFlare's DNS. Needed because wifi DNS was
  # broken for a Riad Dar Naai in Marrakech.

  # This sometimes breaks wifi captive portals.

  networking.nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];

  services.resolved = {
    enable = true;
    dnssec = "true"; # Breaks mass.gov
    domains = ["~."];
    fallbackDns = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
    # dnsovertls = "true"; # This breaks connecting to harvard.edu on Harvard wifi.
  };

  /*
  # IPFS
  services.kubo = {
    enable = true;
  };
  users.users.waltmck.extraGroups = [config.services.kubo.group];
  */
}
