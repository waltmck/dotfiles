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
    ../packages/passwords
    ../packages/firefox
    ../packages/obsidian
    # ../packages/vscode
    ../packages/kitty
    ../packages/music
    ../packages/messaging
    ../packages/rss
    ../packages/gaming
    ../packages/email
    ../packages/torrent
    ../packages/preview
    ../packages/nautilus.nix

    ../services/gnome
    ../services/hyprland
    ../services/bluetooth
    ../services/audio
    ../services/internet
  ];

  # -- System Packages --

  environment.systemPackages = with pkgs; [
    playerctl

    geary
    # cheese
    guvcview
    baobab
    # gnome-text-editor
    gnome-calendar
    gnome-boxes
    gnome-system-monitor
    gnome-control-center
    gnome-weather
    gnome-calculator
    gnome-clocks
    gnome-maps
    gnome-photos
    gnome-contacts
    seahorse
    gnome-power-manager
    # gnome-secrets
    gnome-logs # systemd logs
    endeavour # tasks manager
    networkmanagerapplet

    evolution # Necessary to configure FastMail calendar for God knows what reason
    # gnome-software # for flatpak

    # gui
    obsidian
    (mpv.override {scripts = [mpvScripts.mpris];})
    libreoffice
    # spotify <- no aarch64-linux support
    # caprine-bin # <- no aarch64-linux support
    d-spy
    # gimp
    # discord <- no aarch64-linux support
    icon-library
    dconf-editor

    # fun
    glow
    slides
    # yabridge < no aarch64-linux support
    # yabridgectl <- no aarch64-linux support
    # wine-staging <- no aarch64-linux support

    setzer # LaTex

    passes # Passes manager

    # File Readers

    papers # PDF reader
    zathura # Another PDF viewer
    xournalpp # PDF annotator

    celluloid # Video player
    delfin # Jellyfin streaming
    foliate # ebook reader
    loupe # Image viewe

    shortwave # Internate radio
    wike # wikipedia reader
    gnome-podcasts # Podcasts

    zim # Notes app to try

    ## COMMUNICATION

    g4music
    cozy

    notify-client #ntfy client

    varia # Download manager, wraps aria2

    slack-term # Slack client

    inputs.zotero-nix.packages.${system}.default

    # cozy # Audiobooks
  ];

  environment.persistence."/nix/state".users.waltmck.directories = [
    "Zotero"
    ".config/delfin"
    "Books"
    "Audiobooks"
    ".local/share/cozy"
    ".cache/cozy"
    "Papers"
    "Notepad"
  ];
}
