{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    flare-signal
    signal-desktop
  ];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [".local/share/flare"];
  };
}
