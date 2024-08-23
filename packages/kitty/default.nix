{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [pkgs.kitty];

  home-manager.sharedModules = [
    {
      programs.kitty = {
        enable = true;

        settings = {
          confirm_os_window_close = 0;
          enable_audio_bell = false;
          update_check_interval = 0;
          touch_scroll_multiplier = "2.0";
        };

        font = {
          name = "CaskaydiaCove Nerd Font";
          size = 11;
        };

        theme = "VSCode_Dark";

        shellIntegration.enableZshIntegration = true;
      };
    }
  ];
}
