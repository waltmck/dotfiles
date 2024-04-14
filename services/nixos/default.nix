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

  # nix
  documentation.nixos.enable = false; # .desktop
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixFlakes;
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  # camera
  programs.droidcam.enable = true;

  # virtualisation
  programs.virt-manager.enable = true;
  virtualisation = {
    #podman.enable = true;
    #docker.enable = true;
    #libvirtd.enable = true;
  };

  # dconf
  programs.dconf.enable = true;

  # packages
  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
  ];

  # services
  services = {
    xserver = {
      enable = true;
      excludePackages = [pkgs.xterm];
    };
    printing.enable = true;
    # flatpak.enable = true;
  };

  # logind
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
    HandleLidSwitch=suspend
    HandleLidSwitchExternalPower=ignore
  '';

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
    programs.home-manager.enable = true;

    news.display = "show";

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
    };

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
      "file://${home}/Music"
      "file://${home}/Pictures"
      "file://${home}/Videos"
      "file://${home}/Downloads"
      "file://${home}/Desktop"
      "file://${home}/Work"
      "file://${home}/Projects"
      "file://${home}/Vault"
      "file://${home}/Vault/School School"
      "file://${home}/.config Config"
      "file://${home}/.local/share Local"
    ];

    services = {
      kdeconnect = {
        enable = true;
        indicator = true;
      };
    };
  };

  # -- Persistence --
  environment.persistence."/nix/state" = {
    files = [
      "/etc/machine-id"
    ];
  };

  users.mutableUsers = false;

  users.users = {
    root.initialHashedPassword = "$6$EkkeNxXqJ8H12NTS$cgxh3gdWgQTPhZrojyO1TOGdTUH8qWm/184uLBIjTkYpfgJEOQlRXxQuoGgXvskcYAjRS1WcpO04VzzBo4WNw/";

    waltmck = {
      initialHashedPassword = "$6$EkkeNxXqJ8H12NTS$cgxh3gdWgQTPhZrojyO1TOGdTUH8qWm/184uLBIjTkYpfgJEOQlRXxQuoGgXvskcYAjRS1WcpO04VzzBo4WNw/";
      isNormalUser = true;
      extraGroups = ["wheel" "sudo" "networkmanager"];

      openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDIhzYxT+Dociep+0p5a2xr9T8UDJYCa9wbYRNux4LN2 walt@waltmckelvie.com"];
    };
  };

  time.timeZone = "America/New_York";
}
