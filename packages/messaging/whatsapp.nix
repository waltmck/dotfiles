{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [pkgs.zapzap];

  # Remember to enable "run in background" and "start in background" in the Signal user settings
  systemd.user.services.zapzap = {
    enable = true;
    description = "ZapZap Background Service";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];

    unitConfig = {
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    # Running through `zsh` so that it respects my user environment variables. This is not "best practice" but it is actually the easiest way to get this to work.
    script = ''
      ${pkgs.zsh}/bin/zsh -lc "${pkgs.zapzap}/bin/zapzap"
    '';
  };

  environment.persistence."/nix/state".users.waltmck = {
    directories = [".local/share/ZapZap"];
  };
}
