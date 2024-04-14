{
  config,
  lib,
  pkgs,
  inputs,
  system,
  asztal,
  ...
}: {
  imports = [
    "${inputs.home-manager}/nixos"
  ];

  home-manager.extraSpecialArgs = {
    inherit inputs;
    inherit asztal;
  };

  home-manager.users.waltmck = {
    # Import aylur's home.nix
    imports = [../../aylur/nixos/home.nix];
  };
}
