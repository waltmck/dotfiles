{ config, lib, pkgs, home-manager, impermanence, ... }:

{
  imports = [ "${home-manager}/nixos" ];

  home-manager.users.waltmck = {
    imports = [ "${impermanence}/home-manager.nix" ];

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

    # wayland.windowManager.hyprland = {
    #   enable = true;
    # };

    home.stateVersion = "23.11";
  };
}