{
  config,
  lib,
  pkgs,
  inputs,
  system,
  # pkgs86,
  ...
}: {
  environment.systemPackages = with pkgs; [
    lutris
    cartridges

    # Putting this here since it is x86 only
    zoom-us

    slack
  ];

  programs.steam.enable = true;
}
