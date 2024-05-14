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

  environment.persistence."/nix/state".users.waltmck = {
    directories = [".cache/spot"];
  };
}
