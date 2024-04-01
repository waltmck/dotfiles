{ config, lib, pkgs, inputs, ... }:

{
  imports = [ "${inputs.home-manager}/nixos" ];

  environment.systemPackages = [ pkgs.git ];

  home-manager.users.waltmck = {
    programs.git = {
      enable = true;

      userName = "Walter McKelvie";
      userEmail = "walt@mckelvie.org";
    };
  };
}