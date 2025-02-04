{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [
    # pkgs.legcord
    # pkgs.dissent
    (pkgs.vesktop.override {withSystemVencord = true;})
    pkgs.vencord
  ];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".config/LegCord"
      ".config/dissent"
      ".cache/dissent"
      ".config/vesktop"
    ];
  };
}
