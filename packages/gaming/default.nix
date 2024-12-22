{
  config,
  lib,
  pkgs,
  inputs,
  pkgs86,
  ...
}: {
  environment.systemPackages = with pkgs; [
    prismlauncher
    pkgs86.hello
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
