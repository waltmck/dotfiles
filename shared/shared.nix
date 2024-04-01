# Platform-agnostic configuration

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./home.nix
      "${inputs.home-manager}/nixos"
      "${inputs.impermanence}/nixos.nix"
    ];

  # -- Environment Variables --

  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";

    EDITOR = "nvim";
    TERMINAL = "wezterm";

    # Not officially in the specification
    XDG_BIN_HOME    = "$HOME/.local/bin";
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
      packages = with pkgs; [
        firefox
        vim
        htop
        vscode
        wezterm
        pulseaudio
        home-manager
        obsidian
      ];

      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDIhzYxT+Dociep+0p5a2xr9T8UDJYCa9wbYRNux4LN2 walt@waltmckelvie.com" ];
    };
  };

  time.timeZone = "America/NewYork";

  # -- Desktop Environment --
  
  # programs.hyprland = {
  #   enable = true;
  #   xwayland.enable = true;
  # };

  # Switch to xfce for debugging
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
    displayManager.defaultSession = "xfce";
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # -- System Packages --

  environment.systemPackages = with pkgs; [
    git
    clang
    openssh
    ncdu
    neofetch
    pciutils
    neovim
    wl-clipboard
    brightnessctl
    kitty

    waybar

    dunst # Notifications
    libnotify # dunst dependency

    rofi-wayland # app launcher
  ];

  # -- SSH Configuration --

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # -- 1Password Configuration --
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["waltmck"];
  };

  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      firefox
    '';
    mode = "0755";
  };
  
  # -- Persistence --
  environment.persistence."/nix/state" = {
    directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/iwd"
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

  system.stateVersion = "24.05"; # Did you read the comment?

}

