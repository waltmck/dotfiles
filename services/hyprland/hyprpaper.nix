{
  pkgs,
  inputs,
  config,
  system,
  ...
}: {
  home-manager.users.waltmck = {
    ## Hypridle

    home.file.".config/hypr/hyprpaper.conf" = {
      text = let
        wallpaper = ../../assets/wallpaper.png;
      in ''
        preload = ${wallpaper}

        wallpaper = ,${wallpaper}

        splash = false

        ipc = off
      '';
    };
  };

  systemd.user.services.hyprpaper = {
    description = "Hyprland's paper daemon";
    documentation = ["https://wiki.hyprland.org/Hypr-Ecosystem/hyprpaper"];
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    wantedBy = ["graphical-session.target"];

    unitConfig = {
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    serviceConfig = {
      Type = "simple";
      ExecStart = "${inputs.hyprpaper.packages.${pkgs.system}.default}/bin/hyprpaper";
      Restart = "on-failure";
    };
  };
}
