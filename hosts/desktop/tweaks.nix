{
  home-manager.users.waltmck.wayland.windowManager.hyprland.settings = {
    monitor = [
      # "eDP-1, 1920x1080, 0x0, 1"
      # "HDMI-A-1, 2560x1440, 1920x0, 1"
      # ",preferred,auto,1.5"
      "DP-1, 3840x2160@240, 0x0, 1.6"
    ];
  };

  home-manager.users.waltmck.programs.firefox = {
    "mousewheel.default.delta_multiplier_y" = 80;
    "mousewheel.default.delta_multiplier_x" = 40;
  };
}
