# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let 
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  };
  impermanence = builtins.fetchTarball {
    url =
      "https://github.com/nix-community/impermanence/archive/master.tar.gz";
  };
  apple-silicon-support = builtins.fetchTarball {
    url = 
      "https://github.com/tpwrules/nixos-apple-silicon/archive/main.tar.gz";
  };
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./home.nix
      "${apple-silicon-support}/apple-silicon-support"
      "${home-manager}/nixos"
      "${impermanence}/nixos.nix"
    ];

  # -- Filesystem and Boot Stuff --

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  

  boot.initrd.luks.devices."encrypted" = {
    device = "/dev/disk/by-uuid/0caf6fe9-a9e6-4f18-ada4-a9acc1609799";
    bypassWorkqueues = true;
    allowDiscards = true;
  };

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=2G" "mode=755" ];
  };

  boot.initrd.kernelModules = ["usb_storage" "usbhid" "dm-crypt" "xts" "encrypted_keys" "ext4" "dm-snapshot"];

  
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

  # -- Networking --
  
  networking.hostName = "walt-laptop"; # Define your hostname.
  
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  # -- Desktop Environment --
  
  programs.hyprland = {
    enable = true;
    #  xwayland.enable = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  hardware.asahi = {
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
    setupAsahiSound = true;
    withRust = true;
  };

  # -- Audio --

  hardware.bluetooth.enable = true;
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  sound.enable = true;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # services.jack.jackd.enable = true;
  
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

  system.stateVersion = "24.05"; # Did you read the comment?

}

