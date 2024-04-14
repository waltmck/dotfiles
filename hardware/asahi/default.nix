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

    exec-once = [
      "pactl set-default-sink audio_effect.j413-convolver > /home/waltmck/pactl_logs"
    ];

    input.touchpad = {
      natural_scroll = "yes";
      disable_while_typing = true;
      drag_lock = true;
      tap-to-click = false;
      scroll_factor = 0.2;
      clickfinger_behavior = 1;
    };

    gestures = {
      workspace_swipe = true;
      workspace_swipe_forever = true;
      workspace_swipe_numbered = true;
    };
  };

  home-manager.users.waltmck.home.file.".config/hypr/per-app/asahi.conf" = {
    text = ''
      ${builtins.readFile ./hyprland.conf}
    '';
  };

  sound.enable = true;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber = {
      enable = true;

      # Disable unused virtual device
      configPackages = [
        (pkgs.writeTextDir "share/wireplumber/main.lua.d/51-alsa-disable.lua" ''
          rule = {
            matches = {
              {
                { "device.name", "equals", "alsa_card.platform-snd_aloop.0" },
              },
            },
            apply_properties = {
              ["device.disabled"] = true,
            },
          }

          table.insert(alsa_monitor.rules,rule)
        '')
      ];
    };
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}
