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
  ];

  programs.steam.enable = true;
}
