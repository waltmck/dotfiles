{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  home-manager.users.waltmck.imports = [./home.nix];
}
