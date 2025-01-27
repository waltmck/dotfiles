{lib, ...}: {
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

  services.scaling = {
    enable = true;
    factor = "1.6";
  };

  home-manager.users.waltmck.programs.firefox.profiles.default.settings = {
    "mousewheel.default.delta_multiplier_y" = 40;
    "mousewheel.default.delta_multiplier_x" = 20;
  };

  # Dynamically set timezone since we are a laptop

  services.automatic-timezoned.enable = true;

  services.geoclue2 = {
    enable = true;
    enableDemoAgent = true;

    # MLS was shut down, so we need to use this. nixpkgs will probably make this its new default.
    geoProviderUrl = "https://api.positon.xyz/v1/geolocate?key=56aba903-ae67-4f26-919b-15288b44bda9"; #"https://api.beacondb.net/v1/geolocate";
  };

  services.avahi.enable = true;

  # If we don't know where we are, default to east coast
  time.timeZone = lib.mkDefault "America/New_York";

  # Don't shut down on power key, show the menu
  services.logind.powerKey = "ignore";
}
