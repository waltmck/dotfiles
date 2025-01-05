{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}: {
  imports =
    (
      if system == "x86_64-linux"
      then [./x86-gaming.nix]
      else []
    )
    ++ (
      if system == "aarch64-linux"
      then [./aarch-gaming.nix]
      else []
    );
  environment.systemPackages = with pkgs; [
    prismlauncher
    ares
  ];

  nixpkgs.config.allowUnsupportedSystem = true;

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".local/share/Steam"
      ".steam"
    ];
  };
}
