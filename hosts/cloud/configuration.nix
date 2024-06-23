# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Needed for initial boot
    ./hardware-configuration.nix
    ./disko.nix

    # Extra stuff
    ../../targets/headless.nix
    ../../services/cloud
  ];

  # Disable impermanence because it is buggy and often causes failure to boot
  environment.persistence."/nix/state".enable = false;

  boot.kernelModules = ["kvm-intel"];

  # Do not remove this, otherwise recovery OS may stop working.
  boot.loader.efi.canTouchEfiVariables = false;

  boot.loader.systemd-boot = {
    enable = true;
  };

  /*
  boot.loader.grub = {
    enable = true;
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  */

  # boot.loader.grub.device = "/dev/nvme0n1";

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

  networking.hostName = "walt-cloud"; # Define your hostname.
  networking.hostId = "deadbeef";

  environment.systemPackages = with pkgs; [git vim busybox];

  system.stateVersion = "24.11"; # Did you read the comment?
}
