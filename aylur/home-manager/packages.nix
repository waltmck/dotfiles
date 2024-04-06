{pkgs, ...}: {
  imports = [
    ./scripts/blocks.nix
    ./scripts/nx-switch.nix
    ./scripts/vault.nix
  ];

  xdg.desktopEntries = {
    "lf" = {
      name = "lf";
      noDisplay = true;
    };
  };

  home.packages = with pkgs;
  with gnome; [
    # gui
    obsidian
    (mpv.override {scripts = [mpvScripts.mpris];})
    # libreoffice
    # spotify <- no aarch64-linux support
    # caprine-bin # <- no aarch64-linux support
    d-spy
    github-desktop
    gimp
    transmission_4-gtk
    # discord <- no aarch64-linux support
    teams-for-linux
    icon-library
    dconf-editor
    gnome-secrets

    # tools
    # steam-run # fhs envs <- no aarch64 support
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

    # fun
    glow
    slides
    # yabridge < no aarch64-linux support
    # yabridgectl <- no aarch64-linux support
    # wine-staging <- no aarch64-linux support
  ];
}
