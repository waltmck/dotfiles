{
  pkgs,
  inputs,
  config,
  asztal,
  ...
}: {
  imports = [
    "${inputs.home-manager}/nixos"
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

  home-manager.users.waltmck = {
    imports = [./dconf.nix];

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
}
