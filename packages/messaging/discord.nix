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
    pkgs.vesktop
  ];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".config/ArmCord"
      ".config/dissent"
      ".cache/dissent"
      ".config/vesktop"
    ];
  };
}
