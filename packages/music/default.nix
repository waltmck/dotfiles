{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [pkgs.g4music];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [".cache/com.github.neithern.g4music"];
  };
}
