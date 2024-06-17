# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../targets/headless.nix
  ];

  nixpkgs.overlays = [inputs.nix-on-droid.overlays.default];

  networking.firewall.allowedTCPPorts = [22];
  services.openssh.enable = true;

  users.mutableUsers = false;

  nix.settings.experimental-features = "nix-command flakes";

  /*
    users.users.recovery = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDIhzYxT+Dociep+0p5a2xr9T8UDJYCa9wbYRNux4LN2"
    ];

    extraGroups = ["users" "wheel" "sudo" "networkmanager"];

    isNormalUser = true;
    initialPassword = "hunter3";
  };
  */

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDIhzYxT+Dociep+0p5a2xr9T8UDJYCa9wbYRNux4LN2"
    ];

    # initialPassword = "hunter3";
  };

  /*
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=16G" "mode=755"];
  };
  */

  networking.hostName = "walt-phone"; # Define your hostname.
  networking.hostId = "deadbeaf";

  environment.systemPackages = with pkgs; [git vim busybox];

  system.stateVersion = "24.11"; # Did you read the comment?
}
