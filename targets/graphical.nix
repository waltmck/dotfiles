# Platform-agnostic configuration
{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  ...
}:
assert !headless; {
  imports = [
    ../packages/_1password
    ../packages/firefox
    ../packages/obsidian
    ../packages/vscode
    ../packages/kitty
    # ../packages/blackbox
    ../packages/spot
    ../packages/matrix
    ../packages/newsflash
    ../packages/discord
    ../packages/gaming
    ../packages/alacritty
    ../packages/email

    ../services/gnome
    ../services/hyprland
    ../services/bluetooth
    ../services/audio
  ];

  # -- System Packages --

  environment.systemPackages = with pkgs;
  with gnome; [
    playerctl

    nautilus
    geary
    cheese
    baobab
    gnome-text-editor
    gnome-calendar
    gnome-boxes
    gnome-system-monitor
    gnome-control-center
    gnome-weather
    gnome-calculator
    gnome-clocks
    gnome-maps
    gnome-contacts
    gnome-power-manager
    # gnome-secrets
    gnome-logs # systemd logs
    endeavour # tasks manager

    # evolution # Necessary to configure FastMail calendar for God knows what reason
    # gnome-software # for flatpak

    # gui
    obsidian
    (mpv.override {scripts = [mpvScripts.mpris];})
    libreoffice
    # spotify <- no aarch64-linux support
    # caprine-bin # <- no aarch64-linux support
    d-spy
    # gimp
    transmission_4-gtk
    # discord <- no aarch64-linux support
    icon-library
    dconf-editor

    # fun
    glow
    slides
    # yabridge < no aarch64-linux support
    # yabridgectl <- no aarch64-linux support
    # wine-staging <- no aarch64-linux support

    wezterm

    setzer # LaTex
    passes # Passes manager

    # File Readers

    evince # PDF reader
    celluloid # Video player
    foliate # ebook reader
    loupe # Image viewer

    ## COMMUNICATION

    flare-signal # Signal client
    polari # IRC client
    paper-plane # Telegram client
    calls # Gnome Calls, a voip client

    keepassxc
  ];
}
