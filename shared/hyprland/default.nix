# Platform-agnostic configuration

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      "${inputs.home-manager}/nixos"
      "${inputs.impermanence}/nixos.nix"
    ];

  # -- Desktop Environment --

  services.xserver.displayManager.startx.enable = true;
  
  programs.hyprland = {
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    enable = true;
    xwayland.enable = true;
  };

  # Polkit for permissions
  security = {
    polkit.enable = true;
    # pam.services.ags = {};
  };

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  # Switch to xfce for debugging
  # services.xserver = {
  #   enable = true;
  #   desktopManager = {
  #     xterm.enable = false;
  #     xfce.enable = true;
  #   };
  #   displayManager.defaultSession = "xfce";
  # };
  

  
  services.greetd = let
    tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
    hyprland-session = "${inputs.hyprland.packages.${pkgs.system}.hyprland}/share/wayland-sessions";
  in {
    enable = true;
    settings = {
      default_session = {
        command = "${tuigreet} --time --remember --remember-session --sessions ${hyprland-session}";
        user = "greeter";
      };
    };
  };

  # this is a life saver.
  # literally no documentation about this anywhere.
  # might be good to write about this...
  # https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how/
  systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Without this errors will spam on screen
      # Without these bootlogs will spam on screen
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
  };

  home-manager.users.waltmck.wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    systemd.enable = true;
    xwayland.enable = true;

    settings = {
      # bind =
      #   [
      #     "SUPER, F, exec, ${pkgs.firefox}"
      #     # ", Print, exec, grimblast copy area"
      #     "SUPER, S, exec, ${pkgs.rofi-wayland} -show drun -show-icons"
      #   ];

      exec-once = [
        "hyprctl setcursor Qogir 24"
      ];

      monitor = [
        # "eDP-1, 1920x1080, 0x0, 1"
        # "HDMI-A-1, 2560x1440, 1920x0, 1"
        ",preferred,auto,1"
      ];

      general = {
        layout = "dwindle";
        resize_on_border = true;
        no_cursor_warps = true;
      };

      misc = {
        disable_splash_rendering = true;
        force_default_wallpaper = 1;
      };

      input = {
        follow_mouse = 1;
        touchpad = {
          natural_scroll = "yes";
          disable_while_typing = true;
          drag_lock = true;
        };
        sensitivity = 0;
        float_switch_override_focus = 2;
      };

      binds = {
        allow_workspace_cycles = true;
      };

      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
        # no_gaps_when_only = "yes";
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_forever = true;
        workspace_swipe_numbered = true;
      };

      #input = {
      #  float_switch_override_focus = 1;
      #  follow_mouse = 1;
      #  natural_scroll = 0;
      #  sensitivity = 0;

      #  touchpad = {
      #      clickfinger_behavior = 1;
      #      disable_while_typing = 1;
      #      natural_scroll = 1;
      #      tap-to-click = 1;
      #  };
      #};
    };
  };
}

