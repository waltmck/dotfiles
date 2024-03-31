{ config, lib, pkgs, ... }:

let 
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  };
  impermanence = builtins.fetchTarball {
    url =
      "https://github.com/nix-community/impermanence/archive/master.tar.gz";
  };
in {
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

    wayland.windowManager.hyprland = {
      enable = true;

      extraConfig = ''
        env = MESA_GL_VERSION_OVERRIDE,3.3
        env = MESA_GLSL_VERSION_OVERRIDE,330
        env = MESA_GLES_VERSION_OVERRIDE,3.1
      '';
    };

    home.stateVersion = "23.11";
  };
}