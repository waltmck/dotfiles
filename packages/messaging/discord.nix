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

    # Maintaining arch-specific patches for now
    /*
    (pkgs.vesktop.override {withSystemVencord = true;})
    pkgs.vencord
    */
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
