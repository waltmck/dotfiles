{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [pkgs.fractal];

  home-manager.users.waltmck.wayland.windowManager.hyprland.settings.exec-once = [
    "${pkgs.fractal}/bin/fractal --gapplication-service" # To get background notifications
  ];

  home-manager.users.waltmck = {
    home.persistence."/nix/state/home/waltmck" = {
      directories = [".local/share/fractal"];
    };
  };
}
