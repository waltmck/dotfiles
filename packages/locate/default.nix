{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  services.locate = {
    enable = true;
    package = pkgs.plocate;
    localuser = null;

    output = "/var/cache/locatedb/locatedb";

    prunePaths = [
      "/tmp"
      "/var/tmp"
      "/var/cache"
      "/var/lock"
      "/var/run"
      "/var/spool"
      "/nix/store"
      "/nix/var/log/nix"
      "/nix/state"
    ];
  };

  environment.systemPackages = let
    locate =
      pkgs.writeShellScriptBin "locate"
      ''
        ${pkgs.plocate}/bin/plocate --database /var/cache/locatedb/locatedb "$@" | sort -u
      '';
    updatedb =
      pkgs.writeShellScriptBin "updatedb"
      ''
        ${pkgs.plocate}/bin/updatedb "$@" --output /var/cache/locatedb/locatedb
      '';
  in [
    (lib.hiPrio locate)
    (lib.hiPrio updatedb)
  ];

  users.users.waltmck.extraGroups = ["plocate"];

  # Persist locatedb
  environment.persistence."/nix/state" = {
    directories = [
      {
        directory = "/var/cache/locatedb";
        group = "plocate";
      }
    ];
  };
}
