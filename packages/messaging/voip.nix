{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    calls
  ];
  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".local/share/calls"
      ".config/calls"
    ];
  };
}
