{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = ["${inputs.home-manager}/nixos"];

  environment.systemPackages = [pkgs.firefox];

  home-manager.users.waltmck = {
    home.persistence."/nix/state/home/waltmck" = {
      directories = [".mozilla"];
    };

    home.file.".config/hypr/per-app/firefox.conf" = {
      text = ''
        bind = $mainMod, W, exec, ${pkgs.firefox}/bin/firefox
      '';
    };
  };
}
