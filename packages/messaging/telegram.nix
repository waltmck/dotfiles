{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    paper-plane
    telegram-desktop
  ];

  # Start in background
  systemd.user.services.telegram = {
    enable = true;
    description = "Telegram Background Service";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];

    serviceConfig.Environment = ["PATH=${lib.makeBinPath [pkgs.telegram-desktop]}:/run/current-system/sw/bin/"];

    # Running through `zsh` so that it respects my user environment variables. This is not "best practice" but it is actually the easiest way to get this to work.
    script = ''
      telegram-desktop -startintray
    '';
  };

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".local/share/paper-plane"
      ".local/share/TelegramDesktop"
    ];
  };
}
