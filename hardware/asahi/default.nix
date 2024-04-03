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
      ",preferred,auto,2"
    ];

    exec-once = [
      "pactl set-default-sink audio_effect.j413-convolver > /home/waltmck/pactl_logs"
    ];

    input.touchpad = {
      natural_scroll = "yes";
      disable_while_typing = true;
      drag_lock = true;
      tap-to-click = false;
      scroll_factor = 0.5;
      clickfinger_behavior = 1;
    };
  };

  home-manager.users.waltmck.home.file.".config/hypr/per-app/asahi.conf" = {
    text = ''
      ${builtins.readFile ./hyprland.conf}
    '';
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}
