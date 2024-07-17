{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # flare-signal
    signal-desktop
  ];

  # TODO: debug signal systemd process
  /*
  # Remember to enable "run in background" and "start in background" in the Signal user settings
  systemd.user.services.signal = {
    enable = true;
    description = "Signal Background Service";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];

    # Running through `zsh` so that it respects my user environment variables. This is not "best practice" but it is actually the easiest way to get this to work.
    script = ''
      ${pkgs.zsh}/bin/zsh -lc "${pkgs.signal-desktop}/bin/signal-desktop"
    '';
  };
  */

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      # ".local/share/flare"
      ".config/Signal"
    ];
  };
}
