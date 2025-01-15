{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    flare-signal
    signal-desktop
  ];

  # TODO: debug signal systemd process

  # Remember to enable "run in background" and "start in background" in the Signal user settings
  systemd.user.services.signal = {
    enable = true;
    description = "Signal Background Service";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];

    serviceConfig = {
      Environment = ["PATH=${lib.makeBinPath [pkgs.signal-desktop]}:/run/current-system/sw/bin/"];

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
      signal-desktop --enable-features=UseOzonePlatform --ozone-platform=wayland --start-in-tray
    '';
  };

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".local/share/flare"
      ".config/Signal"
    ];
  };
}
