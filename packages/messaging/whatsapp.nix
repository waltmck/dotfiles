{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  # Removed pending https://github.com/NixOS/nixpkgs/issues/348845
  /*
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
  */

  environment.systemPackages = [pkgs.whatsapp-for-linux];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".cache/whatsapp-for-linux"
      ".local/share/whatsapp-for-linux"
    ];
  };

  systemd.user.services.whatsapp = {
    enable = true;
    description = "WhatsApp Background Service";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];

    unitConfig = {
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    # Running through `zsh` so that it respects my user environment variables. This is not "best practice" but it is actually the easiest way to get this to work.
    script = ''
      ${pkgs.zsh}/bin/zsh -lc "${pkgs.whatsapp-for-linux}/bin/whatsapp-for-linux --gapplication-service"
    '';
  };

  home-manager.sharedModules = [
    {
      xdg.configFile."whatsapp-for-linux/settings.conf" = {
        text = ''
          [general]
          notification-sounds=true
          close-to-tray=true
          start-minimized=true

          [web]
          hw-accel=1
          allow-permissions=true

          [appearance]
          prefer-dark-theme=true
        '';
      };
    }
  ];
}
