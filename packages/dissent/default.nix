{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [pkgs.dissent];

  home-manager.users.waltmck = {
    home.persistence."/nix/state/home/waltmck" = {
      directories = [
        ".config/dissent"
        ".cache/dissent"
      ];
    };
  };
}
