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
  };
}
