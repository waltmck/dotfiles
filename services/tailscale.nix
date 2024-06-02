{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  ...
}: {
  environment.systemPackages = [pkgs.tailscale];

  services.tailscale = {
    enable = true;
  };

  networking.firewall = {
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
    checkReversePath = "loose";
  };
}
