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
    ../packages/sh
    ../packages/git
    ../packages/ssh
    ../packages/tmux
    # ../packages/starship
    ../packages/p10k
    ../packages/kitty

    # ../packages/locate
    ../packages/neovim
    ../packages/lf
    ../packages/aria2.nix
    ../packages/numerical.nix

    ../services/nixos
    ../services/tailscale.nix
    ../services/syncthing.nix
    ../services/iperf3.nix
    ../services/resources.nix
    ../services/virtualization
  ];

  environment.systemPackages = with pkgs; [
    # Common utilities
    sysbench
    toybox
    busybox

    dig.dnsutils
    unrar

    git
    wget
    home-manager
    clang
    openssh
    gdu
    ncdu
    jq
    pciutils
    brightnessctl
    wirelesstools
    speedtest-cli

    bat
    eza
    fd
    ripgrep
    fzf
    libnotify
    killall
    zip
    unzip
    glib
    powertop
    systemctl-tui
    yt-dlp

    # Audio tools
    unflac
    flac
    ffmpeg-headless
    sox

    # Nix tools
    nix-tree
    hydra-check
  ];
}
