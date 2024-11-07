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
      home = {
        sessionVariables.TERMINAL = "${pkgs.kitty}/bin/kitty";
      };
      programs.kitty = {
        enable = true;

        settings = {
          confirm_os_window_close = 0;
          enable_audio_bell = false;
          update_check_interval = 0;
          touch_scroll_multiplier = "2.0";

          clipboard_control = "write-clipboard read-clipboard";
        };

        font = {
          name = "CaskaydiaCove Nerd Font";
          size = 10;
        };

        themeFile = "VSCode_Dark";

        shellIntegration.enableZshIntegration = true;
      };
    }
  ];
}
