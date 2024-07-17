{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [
    pkgs.armcord
    pkgs.dissent
  ];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".config/ArmCord"
      ".config/dissent"
      ".cache/dissent"
    ];
  };
}
