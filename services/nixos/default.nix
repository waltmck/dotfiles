{
  pkgs,
  inputs,
  config,
  asztal,
  ...
}: {
  # Imports and state version
  system.stateVersion = "24.05";
  imports = [
    "${inputs.home-manager}/nixos"
    "${inputs.impermanence}/nixos.nix"
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
    HandleLidSwitchExternalPower=suspend
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

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  home-manager.users.waltmck = {
    # Imports and stateVersion
    home.stateVersion = "23.11";
    imports = ["${inputs.impermanence}/home-manager.nix"];

    programs.home-manager.enable = true;

    news.display = "show";

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
    };
  };

  home-manager.extraSpecialArgs = {
    inherit inputs;
    inherit asztal;
  };

  # -- Persistence --
  environment.persistence."/nix/state" = {
    directories = [
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  home-manager.users.waltmck.home.persistence."/nix/state/home/waltmck" = {
    directories = [
      ".cache/nix" # Nix evaluation cache
    ];
  };

  environment.sessionVariables = rec {
    NIXOS_OZONE_WL = "1";
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  users.mutableUsers = false;

  users.users = {
    root.initialHashedPassword = "$6$EkkeNxXqJ8H12NTS$cgxh3gdWgQTPhZrojyO1TOGdTUH8qWm/184uLBIjTkYpfgJEOQlRXxQuoGgXvskcYAjRS1WcpO04VzzBo4WNw/";

    waltmck = {
      initialHashedPassword = "$6$EkkeNxXqJ8H12NTS$cgxh3gdWgQTPhZrojyO1TOGdTUH8qWm/184uLBIjTkYpfgJEOQlRXxQuoGgXvskcYAjRS1WcpO04VzzBo4WNw/";
      isNormalUser = true;
      extraGroups = ["users" "wheel" "sudo" "networkmanager"];

      openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDIhzYxT+Dociep+0p5a2xr9T8UDJYCa9wbYRNux4LN2 walt@waltmckelvie.com"];
    };
  };

  time.timeZone = "America/New_York";
}
