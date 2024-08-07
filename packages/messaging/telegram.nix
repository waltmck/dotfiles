{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # flare-signal
    paper-plane
  ];
  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".local/share/paper-plane"
    ];
  };
}
