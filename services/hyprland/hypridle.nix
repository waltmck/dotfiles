{
  pkgs,
  inputs,
  config,
  system,
  ...
}: {
  home-manager.users.waltmck = {
    ## Hypridle

    home.file.".config/hypr/hypridle.conf" = {
      text = ''
        general {
            lock_cmd = ${pkgs.busybox}/bin/pidof hyprlock || ${inputs.hyprlock.packages.${pkgs.system}.hyprlock}/bin/hyprlock
            before_sleep_cmd = ${pkgs.systemd}/bin/loginctl lock-session
            after_sleep_cmd = ${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/hyprctl dispatch dpms on
            unlock_cmd = ${pkgs.systemd}/bin/loginctl unlock-sessions
            ignore_dbus_inhibit = false
        }

        listener {
            timeout = 300
            on-timeout = ${pkgs.systemd}/bin/systemctl suspend
        }
      '';
    };
  };

  systemd.user.services.hypridle = {
    description = "Hyprland's idle daemon";
    documentation = ["https://wiki.hyprland.org/Hypr-Ecosystem/hypridle"];
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    wantedBy = ["graphical-session.target"];

    unitConfig = {
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    serviceConfig = {
      Type = "simple";
      ExecStart = "${inputs.hypridle.packages.${pkgs.system}.default}/bin/hypridle";
      Restart = "on-failure";
    };
  };
}
