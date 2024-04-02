{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [pkgs.kitty];

  home-manager.users.waltmck = {
    programs.kitty = {
      enable = true;

      settings = {
        confirm_os_window_close = 0;
      };
    };

    # kitty shortcut
    home.file.".config/hypr/per-app/kitty.conf" = {
      text = ''
        bind = SUPER, Y, exec, ${pkgs.kitty}/bin/kitty
      '';
    };
  };
}
