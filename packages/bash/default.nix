{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = ["${inputs.home-manager}/nixos"];

  home-manager.users.waltmck = {
    imports = ["${inputs.impermanence}/home-manager.nix"];

    programs.bash = {
      enable = true;

      shellAliases = {
        ll = "ls -la";
        rebuild-boot = "sudo nixos-rebuild boot --flake /etc/nixos#walt-laptop --impure";
        rebuild-switch = "sudo nixos-rebuild switch --flake /etc/nixos#walt-laptop --impure";
      };
    };
  };
}
