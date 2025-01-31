{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    slack
  ];

  # Start in background
  systemd.user.services.slack = {
    enable = true;
    description = "Slack Background Service";
    wantedBy = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];

    serviceConfig = {
      Environment = [
        "PATH=${lib.makeBinPath [pkgs.slack]}:/run/current-system/sw/bin/"

        "ELECTRON_OZONE_PLATFORM_HINT=wayland" # Launch apps in wayland
        "NIXOS_OZONE_WL=1"
        "MOZ_ENABLE_WAYLAND=1"
        "XDG_BACKEND=wayland"
        "XDG_SESSION_TYPE=wayland"
      ];

      PassEnvironment = [
        "BROWSER"
        "XDG_CONFIG_DIRS"
        "XDG_BACKEND"
        "XCURSOR_SIZE"
        "XDG_SESSION_TYPE"
        "XDG_CURRENT_DESKTOP"
      ];
    };

    # Running through `zsh` so that it respects my user environment variables. This is not "best practice" but it is actually the easiest way to get this to work.
    script = ''
      ${pkgs.slack}/bin/slack -u
    '';
  };

  home-manager.users.waltmck.wayland.windowManager.hyprland.settings.windowrule = [
    "size 940 703, class:Slack"
  ];
}
