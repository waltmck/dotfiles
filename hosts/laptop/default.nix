# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  inputs,
  march,
  system,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../hardware/asahi
    ./filesystem.nix
    ./tweaks.nix

    ../../targets/headless.nix
    ../../targets/graphical.nix

    ../../modules/optimize.nix

    ../../services/bluetooth
  ];

  boot.binfmt.emulatedSystems = [
    "x86_64-linux"
    # "x86_64-windows"
    "i686-linux"
  ];
  /*
  environment.systemPackages = with pkgs; [box64];

  boot.binfmt.registrations = {
    x86_64-linux = {
      magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';
      mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
      interpreter = "${pkgs.box64}/bin/box64";
    };
    x86_64-windows = {
      magicOrExtension = "MZ";
      interpreter = "${pkgs.box64}/bin/box64";
    };
  };
  */

  # See installation notes for how to find this
  boot.initrd.luks.devices."encrypted".device = "/dev/disk/by-uuid/0caf6fe9-a9e6-4f18-ada4-a9acc1609799";

  services.optimize = {
    enable = true;
    inherit march;

    packages = {
      # Hypr ecosystem
      hyprland.cflags = "-Ofast";
      aquamarine.cflags = "-Ofast";
      hyprcursor.cflags = "-Ofast";
      hyprutils.cflags = "-Ofast";

      # We need to rebuild systemd anyway so why not?
      systemdPatched.cflags = "-O3";

      # Why does this lead to rebuilding ffmpeg, neovide, qemu?
      # pipewire.cflags = "-O3";
      # wireplumber.cflags = "-Ofast";
    };
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}
