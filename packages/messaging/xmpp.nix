{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    dino
    gajim
  ];
  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".local/share/dino"

      ".local/share/gajim"
      ".config/gajim"
      ".cache/gajim"
    ];
  };

  systemd.user.services.dino = {
    enable = true;
    description = "Dino XMPP Background Service";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];

    serviceConfig = {
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
      ${pkgs.zsh}/bin/zsh -lc "${pkgs.dino}/bin/dino --gapplication-service"
    '';
  };
}
