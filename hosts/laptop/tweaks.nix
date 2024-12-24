{
  home-manager.users.waltmck.wayland.windowManager.hyprland.settings = {
    monitor = [
      # "eDP-1, 1920x1080, 0x0, 1"
      # "HDMI-A-1, 2560x1440, 1920x0, 1"
      # ",preferred,auto,1.5"
      "eDP-1, 2560x1664@60, 0x0, 1.6"
    ];

    # exec-once = [
    #   "pactl set-default-sink audio_effect.j413-convolver"
    # ];

    input.touchpad = {
      natural_scroll = "yes";
      disable_while_typing = false;
      drag_lock = true;
      tap-to-click = false;
      scroll_factor = 0.5;
      clickfinger_behavior = 1;
    };

    gestures = {
      workspace_swipe = true;
      workspace_swipe_forever = false;

      workspace_swipe_distance = 480;

      workspace_swipe_cancel_ratio = 0.15;
    };

    xwayland.force_zero_scaling = true;
  };

  # Vulkan renderer is slower than opengl renderer on Asahi
  environment.sessionVariables.GSK_RENDERER = "ngl";

  environment.sessionVariables.GDK_SCALE = "1.6";

  home-manager.users.waltmck.programs.firefox.profiles.default.settings = {
    "mousewheel.default.delta_multiplier_y" = 40;
    "mousewheel.default.delta_multiplier_x" = 20;
  };
}
