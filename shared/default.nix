# Platform-agnostic configuration
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    "${inputs.home-manager}/nixos"
    "${inputs.impermanence}/nixos.nix"
  ];

  # -- Environment Variables --

  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    EDITOR = "vim";
    TERMINAL = "kitty";

    # Not officially in the specification
    XDG_BIN_HOME = "$HOME/.local/bin";
    PATH = [
      "${XDG_BIN_HOME}"
    ];

    NIXOS_OZONE_WL = "1";
  };

  # -- User Config --

  nixpkgs.config.allowUnfree = true;

  users.mutableUsers = false;

  users.users = {
    root.initialHashedPassword = "$6$EkkeNxXqJ8H12NTS$cgxh3gdWgQTPhZrojyO1TOGdTUH8qWm/184uLBIjTkYpfgJEOQlRXxQuoGgXvskcYAjRS1WcpO04VzzBo4WNw/";

    waltmck = {
      initialHashedPassword = "$6$EkkeNxXqJ8H12NTS$cgxh3gdWgQTPhZrojyO1TOGdTUH8qWm/184uLBIjTkYpfgJEOQlRXxQuoGgXvskcYAjRS1WcpO04VzzBo4WNw/";
      isNormalUser = true;
      extraGroups = ["wheel" "sudo"];

      openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDIhzYxT+Dociep+0p5a2xr9T8UDJYCa9wbYRNux4LN2 walt@waltmckelvie.com"];
    };
  };

  time.timeZone = "America/New_York";

  # -- System Packages --

  environment.systemPackages = with pkgs; [
    vim
    htop
    pulseaudio
    home-manager
    clang
    openssh
    ncdu
    neofetch
    pciutils
    neovim
    wl-clipboard
    brightnessctl
    playerctl
    wirelesstools

    dunst # Notifications
    libnotify # dunst dependency

    # rofi-wayland # app launcher
  ];

  # -- SSH Configuration --

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # -- Persistence --
  environment.persistence."/nix/state" = {
    directories = [
      "/etc/NetworkManager/system-connections" # WiFi Connections
      "/var/lib/bluetooth" # Bluetooth connections
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  # NixOS
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  home-manager.users.waltmck = {
    imports = ["${inputs.impermanence}/home-manager.nix"];

    programs.home-manager.enable = true;

    xdg.userDirs.enable = true;

    home.persistence."/nix/state/home/waltmck" = {
      directories = ["Downloads" "Documents" "src" ".local/share/keyrings"];
      files = [];

      allowOther = false;
    };

    nixpkgs.config.allowUnfree = true;

    home.stateVersion = "23.11";
  };

  # Networking

  networking.networkmanager.enable = true;

  # bluetooth
  hardware.bluetooth = {
    enable = true;

    settings = {
      General = {
        Name = "walt-laptop";
        ControllerMode = "dual";
        FastConnectable = "true";
        Experimental = "true";

        Enable = "Source,Sink,Media,Socket";
      };
      Policy = {
        AutoEnable = "true";
      };
    };

    powerOnBoot = true;
  };

  services.blueman.enable = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}
