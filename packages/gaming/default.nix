{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    prismlauncher
  ];
  
  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".local/share/Steam" 
      ".steam"
    ];
  };
}
