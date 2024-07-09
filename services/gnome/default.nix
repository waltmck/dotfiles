{
  pkgs,
  inputs,
  config,
  headless,
  ...
}: {
  imports = [
    "${inputs.home-manager}/nixos"
    ./xdg.nix
  ];

  # Hide mounted files from Nautilus
  environment.persistence."/nix/state".hideMounts = true;

  # camera
  programs.droidcam.enable = true;

  # virtualisation
  programs.virt-manager.enable = true;
  virtualisation = {
    #podman.enable = true;
    #docker.enable = true;
    #libvirtd.enable = true;
  };

  programs.dconf.enable = true;

  environment.sessionVariables = {
    QT_XCB_GL_INTEGRATION = "none"; # kde-connect
    NIXPKGS_ALLOW_UNFREE = "1";
    NIXPKGS_ALLOW_INSECURE = "1";
    BAT_THEME = "base16";
    GOPATH = "/home/waltmck/.local/share/go";
    GOMODCACHE = "/home/waltmck/.cache/go/pkg/mod";
    NO_AT_BRIDGE = "1"; # Disable accessibility stuff
  };

  home-manager.users.waltmck = {
    imports = [./dconf.nix];

    home = {
      sessionPath = [
        "$HOME/.local/bin"
      ];
    };

    gtk.gtk3.bookmarks = let
      home = "/home/waltmck";
    in [
      "file://${home}/Documents"
      "file://${home}/Downloads"
      "file://${home}/Videos"
      "file://${home}/Pictures"
      "file://${home}/src Source"
    ];

    xdg.userDirs.enable = true;
  };

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      "Downloads"
      "Documents"
      "Videos"
      "Pictures"
      "Music"
      "src"
      ".local/share/keyrings"
      ".config/dconf" # Keep gnome app settings (including geary, g4music)
      ".config/evolution" # Persist calendars
      ".cache/evolution/calendar"
      ".local/share/evolution/calendar"
      ".cache/evolution/addressbook" # Persist contacts
      ".local/share/evolution/addressbook"
    ];
    files = [];
  };

  # Polkit authentication agent
  systemd = {
    package = pkgs.systemd;

    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  services.gnome = {
    evolution-data-server.enable = true;
    glib-networking.enable = true;
    gnome-keyring = {
      enable = true;
    };
    # Enable to use google or nextcloud
    # gnome-online-accounts.enable = true;
    sushi.enable = true;
  };

  # TODO: fix keyring not unlocking on boot
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
}
