# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./shared/shared.nix
      "${inputs.apple-silicon-support}/apple-silicon-support"
      "${inputs.home-manager}/nixos"
      "${inputs.impermanence}/nixos.nix"
    ];

  # -- Filesystem and Boot Stuff --

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  

  boot.initrd.luks.devices."encrypted" = {
    device = "/dev/disk/by-uuid/0caf6fe9-a9e6-4f18-ada4-a9acc1609799";
    bypassWorkqueues = true;
    allowDiscards = true;
  };

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=8G" "mode=755" ];
  };

  boot.initrd.kernelModules = ["usb_storage" "usbhid" "dm-crypt" "xts" "encrypted_keys" "ext4" "dm-snapshot"];

  # -- Networking --
  
  networking.hostName = "walt-laptop"; # Define your hostname.
  
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  # -- Sound and GPU --

  hardware.bluetooth.enable = true;
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  sound.enable = true;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  hardware.asahi = {
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
    setupAsahiSound = true;
    withRust = true;
  };

  # services.jack.jackd.enable = true;
  
  system.stateVersion = "24.05"; # Did you read the comment?

}

