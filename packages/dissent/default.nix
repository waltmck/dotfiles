{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [pkgs.dissent];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".config/dissent"
      ".cache/dissent"
    ];
  };
}
