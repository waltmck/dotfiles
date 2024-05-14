{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    "${inputs.apple-silicon-support}/apple-silicon-support"
  ];

  # -- Asahi-

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  hardware.asahi = {
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
    setupAsahiSound = true;
    withRust = true;
  };

  # Enable the notch, and swap the fn and control keys
  boot.extraModprobeConfig = ''
    options apple_dcp show_notch=1
    options hid_apple swap_fn_leftctrl=1
  '';

  # services.jack.jackd.enable = true;

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
      disable_while_typing = true;
      drag_lock = true;
      tap-to-click = false;
      scroll_factor = 0.5;
      clickfinger_behavior = 1;
    };

    gestures = {
      workspace_swipe = true;
      workspace_swipe_forever = false;

      workspace_swipe_distance = 480;

      workspace_swipe_cancel_ratio = 0.3;
    };
  };

  home-manager.users.waltmck.home.file.".config/hypr/per-app/asahi.conf" = {
    text = ''
      ${builtins.readFile ./hyprland.conf}
    '';
  };

  # -- Persistence --
  environment.persistence."/nix/state" = {
    files = [
      # "/sys/devices/platform/soc/231c00000.dcp/backlight/apple-panel-bl/brightness" # Persist screen brightness
    ];
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}
