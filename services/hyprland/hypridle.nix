{
  pkgs,
  inputs,
  config,
  system,
  ...
}: {
  environment.systemPackages = [pkgs.hypridle];
  home-manager.users.waltmck = {
    ## Hypridle

    home.file.".config/hypr/hypridle.conf" = {
      text = ''
        general {
            lock_cmd = ${pkgs.busybox}/bin/pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock
            before_sleep_cmd = ${pkgs.systemd}/bin/loginctl lock-session
            after_sleep_cmd = ${config.programs.hyprland.package}/bin/hyprctl dispatch dpms on
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
    partOf = ["hyprland-session.target"];
    after = ["hyprland-session.target"];
    wantedBy = ["hyprland-session.target"];

    unitConfig = {
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hypridle}/bin/hypridle";
      Restart = "always";
      RestartSec = 3;

      Slice = "session.slice";
    };
  };
}
