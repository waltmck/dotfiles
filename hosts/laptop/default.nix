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
    ../../shared
    ../../hardware/asahi
    ../../hardware/filesystem

    ../../targets/headless.nix

    ../../packages/firefox
    ../../packages/obsidian
    ../../packages/vscode
    ../../packages/kitty
    # ../../packages/blackbox
    ../../packages/spot
    ../../packages/fractal
    ../../packages/newsflash
    ../../packages/dissent
    ../../packages/gaming
    ../../packages/alacritty
    ../../packages/email

    ../../services/ags-laptop
    ../../services/gnome
    ../../services/hyprland
    ../../services/bluetooth
    ../../services/audio
  ];

  # See installation notes for how to find this
  boot.initrd.luks.devices."encrypted".device = "/dev/disk/by-uuid/0caf6fe9-a9e6-4f18-ada4-a9acc1609799";

  system.stateVersion = "24.05"; # Did you read the comment?
}
