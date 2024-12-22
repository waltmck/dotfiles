{
  home-manager.users.waltmck.wayland.windowManager.hyprland.settings = {
    monitor = [
      # "eDP-1, 1920x1080, 0x0, 1"
      # "HDMI-A-1, 2560x1440, 1920x0, 1"
      # ",preferred,auto,1.5"
      "DP-1, 3840x2160@120, 0x0, 1.6, bitdepth, 10"
    ];
  };

  home-manager.users.waltmck.programs.firefox.profiles.default.settings = {
    "mousewheel.default.delta_multiplier_y" = 160;
    "mousewheel.default.delta_multiplier_x" = 80;
  };
}
