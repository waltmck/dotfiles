{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = ["${inputs.home-manager}/nixos"];

  environment.systemPackages = [pkgs.obsidian];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [".config/obsidian" "Obsidian"];
  };
}
