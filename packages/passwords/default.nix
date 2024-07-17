{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./1password.nix
    ./keepass.nix
  ];
}
