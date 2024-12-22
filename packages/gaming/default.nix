{
  config,
  lib,
  pkgs,
  inputs,
  system,
  # pkgs86,
  ...
}: {
  imports =
    if system == "x86_64-linux"
    then [./x86-gaming.nix]
    else [];
  environment.systemPackages = with pkgs; [
    prismlauncher
    # pkgs86.hello
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
