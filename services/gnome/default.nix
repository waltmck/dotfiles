{
  pkgs,
  inputs,
  config,
  asztal,
  ...
}: {
  imports = [
    "${inputs.home-manager}/nixos"
    ./xdg.nix
  ];

  # camera
  programs.droidcam.enable = true;

  # virtualisation
  programs.virt-manager.enable = true;
  virtualisation = {
    #podman.enable = true;
    #docker.enable = true;
    #libvirtd.enable = true;
  };

  # kde connect
  networking.firewall = rec {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };

  programs.dconf.enable = true;

  home-manager.users.waltmck = {
    imports = [./dconf.nix ./lf.nix];

    home = {
      sessionVariables = {
        QT_XCB_GL_INTEGRATION = "none"; # kde-connect
        NIXPKGS_ALLOW_UNFREE = "1";
        NIXPKGS_ALLOW_INSECURE = "1";
        BAT_THEME = "base16";
        GOPATH = "/home/waltmck/.local/share/go";
        GOMODCACHE = "/home/waltmck/.cache/go/pkg/mod";
      };

      sessionPath = [
        "$HOME/.local/bin"
      ];
    };

    gtk.gtk3.bookmarks = let
      home = "/home/waltmck";
    in [
      "file://${home}/Documents"
      "file://${home}/Downloads"
      "file://${home}/src Source"
    ];

    home.persistence."/nix/state/home/waltmck" = {
      directories = [
        "Downloads"
        "Documents"
        "src"
        ".local/share/keyrings"
        ".local/share/evolution" # Mail, contacts, calendar, tasks
        ".local/share/geary"
      ];
      files = [];

      allowOther = false;
    };

    services = {
      kdeconnect = {
        enable = true;
        indicator = true;
      };
    };

    xdg.userDirs.enable = true;
  };

  # Polkit authentication agent
  systemd = {
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
    gnome-online-accounts.enable = true;
    sushi.enable = true;
  };

  # TODO: fix keyring not unlocking on boot
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
}
