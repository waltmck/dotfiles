{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [pkgs.zapzap];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [".local/share/ZapZap"];
  };
}
