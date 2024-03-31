{ config, lib, pkgs, ... }:

{
  programs.home-manager.enable = true;

  xdg.userDirs.enable = true;
  
  programs.bash = {
    enable = true;

    shellAliases = {
      ll = "ls -la";
    };
  };

  programs.git = {
    enable = true;

    userName = "Walter McKelvie";
    userEmail = "walt@mckelvie.org";
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
          IdentityAgent ~/.1password/agent.sock
    '';
  };

  home.persistence."/nix/state/home/waltmck" = {
    directories = [ "Downloads" "Documents" ".config/1Password" ".mozilla" ".config/obsidian" "Obsidian"];
    files = [ ];

    allowOther = false;
  };

  home.stateVersion = "23.11";
}