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

    mathematica

    wine-wayland
    gamescope
    mangohud
    gamemode
  ];

  # Following https://gitlab.com/doronbehar/nix-matlab
  # TODO get this working correctly
  home-manager.sharedModules = [
    {
      xdg.configFile."matlab/nix.sh".text = "INSTALL_DIR=/games/matlab";
    }
  ];

  programs.steam.enable = true;
}
