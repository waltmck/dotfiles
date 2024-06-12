{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}: let
  ags = inputs.ags.packages.${pkgs.system}.default;
  deps = with pkgs; [
    ags
    bun
    dart-sass
    fd
    brightnessctl
    # swww
    # inputs.matugen.packages.${system}.default
    slurp
    wf-recorder
    wl-clipboard
    wayshot
    swappy
    hyprpicker
    pavucontrol
    networkmanager
    gtk3
    # hyprland
    systemd
    networkmanagerapplet #TODO link to this from quicksettings
  ];
in {
  home-manager.users.waltmck = {
    imports = [
      inputs.ags.homeManagerModules.default
      inputs.astal.homeManagerModules.default
    ];

    # home.packages = deps;

    programs.astal = {
      enable = true;
      extraPackages = with pkgs; [
        libadwaita
      ];
    };

    programs.ags = {
      enable = true;
      configDir = ./ags;
      # extraPackages = with pkgs; [
      #   accountsservice
      # ];

      package = ags;
    };
  };

  environment.persistence."/nix/state".users.waltmck = {
    directories = [".cache/ags"];
  };

  systemd.user.services.ags = {
    description = "Aylur's Gnome Shell";
    documentation = ["https://aylur.github.io/ags-docs"];
    partOf = ["hyprland-session.target"];
    after = ["hyprland-session.target"];
    wantedBy = ["hyprland-session.target"];

    unitConfig = {
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    serviceConfig = {
      Type = "simple";
      ExecStart = "${ags}/bin/ags -b hypr";

      Environment = let
        path = lib.makeBinPath deps;
      in [
        "PATH=${path}:/run/current-system/sw/bin/"
        "LOGNAME=waltmck"
        "HOME=/home/waltmck"
        "LANG=en_US.UTF-8"
        "XDG_SEAT=seat0"
        "XDG_SESSION_TYPE=tty"
        "XDG_SESSION_CLASS=user"
        "XDG_VTNR=1"
        "XDG_RUNTIME_DIR=/run/user/1000"
        "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
        "HYPRLAND_LOG_WLR=1"

        "ELECTRON_OZONE_PLATFORM_HINT=wayland" # Launch apps in wayland
        "NIXOS_OZONE_WL=1"
        "MOZ_ENABLE_WAYLAND=1"
        "XDG_BACKEND=wayland"
        "XDG_SESSION_TYPE=wayland"

        # CURSOR STUFF
        "XCURSOR_SIZE=24"
        "XCURSOR_THEME=Qogir"
      ];

      Slice = "session.slice";

      StandardOutput = "journal";
      StandardError = "journal";
      Restart = "always";
      RestartSec = 3;
    };
  };
}
