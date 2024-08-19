{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    dino
    gajim
  ];
  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".local/share/dino"

      ".local/share/gajim"
      ".config/gajim"
      ".cache/gajim"
    ];
  };
}
