{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # paper-plane
    telegram-desktop
  ];

  # Start in background
  systemd.user.services.telegram = {
    enable = true;
    description = "Telegram Background Service";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];

    serviceConfig = {
      Environment = [
        "PATH=${lib.makeBinPath [pkgs.telegram-desktop]}:/run/current-system/sw/bin/"
        "XDG_CURRENT_DESKTOP=gnome" # Use gnome file chooser
      ];

      PassEnvironment = [
        "BROWSER"
        "XDG_CONFIG_DIRS"
        "XDG_BACKEND"
        "XCURSOR_SIZE"
        "XDG_SESSION_TYPE"
      ];
    };

    # Running through `zsh` so that it respects my user environment variables. This is not "best practice" but it is actually the easiest way to get this to work.
    script = ''
      telegram-desktop -startintray
    '';
  };

  home-manager.users.waltmck.wayland.windowManager.hyprland.settings.windowrulev2 = [
    "float, title:(Choose Files)"
  ];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".local/share/paper-plane"
      ".local/share/TelegramDesktop"
    ];
  };
}
