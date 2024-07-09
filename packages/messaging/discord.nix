{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  /*
  environment.systemPackages = [pkgs.dissent];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".config/dissent"
      ".cache/dissent"
    ];
  };
  */

  environment.systemPackages = [pkgs.armcord];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".config/ArmCord"
    ];
  };
}
