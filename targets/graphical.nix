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
    ../packages/numerical.nix
    ../packages/llm.nix

    ../services/gnome
    ../services/hyprland
    ../services/ags
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
    gnome-disk-utility
    gnome-contacts
    sound-juicer
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
    # caprine
    d-spy
    icon-library
    dconf-editor

    # GPU/graphics debugging tools
    xorg.xlsclients.out #xlsclients
    virtualgl.out # glxinfo
    vulkan-tools.out # vulkaninfo, vkcube
    vkmark # Vulkan benchmark

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
    xournalpp # PDF annotator

    celluloid # Video player
    delfin # Jellyfin streaming
    foliate # ebook reader
    loupe # Image viewe

    shortwave # Internate radio
    wike # wikipedia reader
    gnome-podcasts # Podcasts
    gpodder

    zim # Notes app to try

    ## COMMUNICATION

    g4music
    cozy
    helvum

    notify-client #ntfy client

    varia # Download manager, wraps aria2

    slack-term # Slack client
    headlines

    inputs.zotero-nix.packages.${system}.default

    # cozy # Audiobooks

    ungoogled-chromium
    epiphany
    deja-dup

    impression # For flashing USB drives

    # Reddit client?
    headlines
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

  # For libreoffice
  fonts.packages = [
    pkgs.corefonts
    pkgs.vistafonts
  ];

  # Autologin on TTY1
  systemd.services."getty@tty1" = {
    overrideStrategy = "asDropin";
    serviceConfig.ExecStart = ["" "@${pkgs.util-linux}/sbin/agetty agetty --login-program ${config.services.getty.loginProgram} --autologin waltmck --noclear --keep-baud %I 115200,38400,9600 $TERM"];
  };
}
