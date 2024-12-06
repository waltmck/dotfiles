{
  pkgs,
  inputs,
  config,
  system,
  ...
}: {
  environment.systemPackages = [pkgs.hyprsunset];

  systemd.user.services.hyprsunset = {
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
      ExecStart = "${pkgs.hyprsunset}/bin/hyprsunset -t 3000";
      Restart = "always";
      RestartSec = 3;

      Slice = "session.slice";
    };
  };
}
