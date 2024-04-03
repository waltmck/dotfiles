{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = ["${inputs.home-manager}/nixos"];

  environment.systemPackages = [pkgs.spot];

  home-manager.users.waltmck.wayland.windowManager.hyprland.settings.exec-once = [
    "${pkgs.spot}/bin/spot --gapplication-service"
  ];

  home-manager.users.waltmck = {
    home.persistence."/nix/state/home/waltmck" = {
      directories = ["/home/waltmck/.cache/spot/librespot"];
    };
  };
}
