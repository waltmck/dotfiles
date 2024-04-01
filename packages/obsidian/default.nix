{ config, lib, pkgs, inputs, ... }:

{
  imports = [ "${inputs.home-manager}/nixos" ];

  environment.systemPackages = [ pkgs.obsidian ];
  
  home-manager.users.waltmck = {
    home.persistence."/nix/state/home/waltmck" = {
      directories = [ ".config/obsidian" "Obsidian" ];
    };
  };
}