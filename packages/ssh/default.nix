{ config, lib, pkgs, inputs, ... }:

{
  imports = [ "${inputs.home-manager}/nixos" ];

  home-manager.users.waltmck = {
    programs.ssh = {
      enable = true;
    };
  };
}