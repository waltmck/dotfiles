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
    # Include the results of the hardware scan.
    inputs.nix-colors.homeManagerModules.default
    ./hardware-configuration.nix
    ../../shared
    ../../hardware/asahi
    ../../hardware/filesystem

    ../../packages/_1password
    ../../packages/sh
    ../../packages/git
    ../../packages/ssh
    ../../packages/firefox
    ../../packages/obsidian
    ../../packages/vscode
    ../../packages/kitty
    ../../packages/blackbox
    ../../packages/spot
    ../../packages/fractal
    ../../packages/tmux
    ../../packages/newsflash
    ../../packages/starship

    # ../../packages/wofi
    # ../../packages/gnome
    # ../../packages/greetd
    # ../../packages/hyprland
    # ../../packages/ags

    ../../services/ags-laptop
    ../../services/gnome
    ../../services/hyprland
    ../../services/nixos
    ../../services/bluetooth
    ../../services/internet
    ../../services/audio
  ];

  # See installation notes for how to find this
  boot.initrd.luks.devices."encrypted".device = "/dev/disk/by-uuid/0caf6fe9-a9e6-4f18-ada4-a9acc1609799";

  # -- Set hostname --

  networking.hostName = "walt-laptop";

  colorScheme = inputs.nix-colors.colorSchemes."horizon-dark";

  system.stateVersion = "24.05"; # Did you read the comment?
}
