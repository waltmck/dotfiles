{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = ["${inputs.home-manager}/nixos"];

  environment.systemPackages = [
    # Fix obsidian rendering issue on Asahi
    /*
    (pkgs.obsidian.override {
      electron = pkgs.electron_33;
    })
    */
  ];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [".config/obsidian" "Obsidian"];
  };
}
