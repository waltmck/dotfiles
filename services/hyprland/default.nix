{
  pkgs,
  inputs,
  config,
  system,
  lib,
  march,
  native,
  ...
}: let
  hyprland = pkgs.hyprland;
  enable-xwayland = true;
in {
  imports = [
    ./theme.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./hyprsunset.nix
    # ./hyprpaper.nix
  ];

  environment.enableDebugInfo = true;

  # Moved from services/nixos. TODO is this necessary?
  services = {
    /*
      xserver = {
      enable = true;
      excludePackages = [pkgs.xterm];
    };
    */
    printing.enable = true;
    # flatpak.enable = true;
  };

  # Make electron apps use Wayland
  environment.sessionVariables = {
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    NIXOS_OZONE_WL = "1";
    GTK_THEME = "adw-gtk3-dark";
  };

  services.xserver.displayManager.startx.enable = true;

  programs.hyprland = {
    enable = true;
    package = hyprland;
    xwayland.enable = enable-xwayland;
  };

  programs.xwayland.enable = enable-xwayland;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Begin user systemd services on boot rather than on login
  users.users.waltmck.linger = true;

  security = {
    polkit.enable = true;
    pam.services.ags = {};
  };

  environment.systemPackages = with pkgs; [
    loupe
    adwaita-icon-theme
    wl-gammactl
    wl-clipboard
    wayshot
    pwvucontrol
    brightnessctl
  ];

  services = {
    gvfs.enable = true;
    # devmon.enable = true;
    upower.enable = true; # For battery indicator
    accounts-daemon.enable = true;
  };

  security.pam.services.greetd.enableGnomeKeyring = true;

  # This fixes the problem of the gnome-keyring not being logged into at boot
  # for reasons outside of my comprehension
  security.pam.services.sddm.enableGnomeKeyring = true;

  # Autostart from TTY1
  home-manager.users.waltmck.programs.zsh.initExtraFirst = ''
    if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
      ${pkgs.systemd}/bin/systemctl start --user hyprland
    fi
  '';

  systemd.user.services.hyprland = {
    description = "Hyprland Window Manager";
    documentation = ["https://wiki.hyprland.org"];
    # after = ["systemd-user-sessions.service" "plymouth-quit-wait.service" "getty@tty1.service" "graphical-session-pre.target"];

    /*
    TODO figure out how to get this to automatically start at boot
    wants = ["graphical-session-pre.target"];
    # before = ["graphical-session.target"];
    conflicts = ["getty@tty1.service"];

    # wantedBy = ["graphical-session.target"];
    # bindsTo = ["graphical-session.target"];
    wantedBy = ["default.target"];
    */

    serviceConfig = {
      Type = "notify";
      ExecStopPost = "${pkgs.systemd}/bin/systemctl --user unset-environment WAYLAND_DISPLAY DISPLAY";
      ExecStart = "${config.programs.hyprland.package}/bin/Hyprland";

      Environment = let
        path = lib.makeBinPath [pkgs.coreutils-full pkgs.gnugrep];
      in [
        "PATH=${path}:/run/current-system/sw/bin/"
        "LOGNAME=waltmck"
        "HOME=/home/waltmck"
        "LANG=en_US.UTF-8"
        "XDG_SEAT=seat0"
        "XDG_SESSION_TYPE=tty"
        "XDG_SESSION_CLASS=user"
        "XDG_VTNR=1"
        "XDG_RUNTIME_DIR=/run/user/1000"
        "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
        "HYPRLAND_LOG_WLR=1"

        # Enable sd_notify
        "HYPRLAND_NO_RT=0"

        # CURSOR STUFF
        "XCURSOR_SIZE=24"
        "HYPRCURSOR_SIZE=24"
        "XCURSOR_THEME=Qogir"

        "GTK_THEME=adw-gtk3-dark"
        # END CURSOR STUFF

        # "WAYLAND_DISPLAY=wayland-1"
        # "DISPLAY=:0"
      ];

      Slice = "session.slice";

      StandardOutput = "journal";
      StandardError = "journal";
      Restart = "no";

      NotifyAccess = "all";
      TimeoutStopSec = 10;
    };
  };

  home-manager.users.waltmck.wayland.windowManager.hyprland = let
    # hyprland = hyprland;
    # plugins = inputs.hyprland-plugins.packages.${pkgs.system};
    hyprctl = "${config.programs.hyprland.package}/bin/hyprctl";

    yt = pkgs.writeShellScript "yt" ''
      notify-send "Opening video" "$(wl-paste)"
      mpv "$(wl-paste)"
    '';

    playerctl = "${pkgs.playerctl}/bin/playerctl";
    brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
    wpctl = "${pkgs.wireplumber}/bin/wpctl";
    ags = "${pkgs.ags}/bin/ags";
  in {
    enable = true;
    package = hyprland;
    systemd.enable = true;
    xwayland.enable = enable-xwayland;
    # plugins = with plugins; [ hyprbars borderspp ];
    # plugins = []; # [hyprspace.packages.${pkgs.system}.Hyprspace];

    settings = {
      exec-once = [
        # Tell systemd we are ready
        "${pkgs.systemd}/bin/systemd-notify --ready"
        "${hyprctl} setcursor Qogir 24"
        # "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
        # "${pkgs.blueman}/bin/blueman-applet"
      ];

      cursor = {
        inactive_timeout = 3;
      };

      general = {
        layout = "dwindle";
        resize_on_border = false;

        gaps_in = 8;
        gaps_out = 5;

        border_size = 1;

        "col.active_border" = "rgba(51a4e7ff)";
        "col.inactive_border" = "rgba(333333ff)";
      };

      debug = {
        disable_logs = false;
      };

      misc = {
        disable_splash_rendering = true;
        disable_hyprland_logo = true;
      };

      render = {
        explicit_sync = false;
      };

      input = {
        follow_mouse = 1;
        sensitivity = 0.25;
        float_switch_override_focus = 2;
      };

      binds = {
        allow_workspace_cycles = true;
      };

      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
      };

      windowrule = let
        f = regex: "float, ^(${regex})$";
      in [
        (f "org.gnome.Calculator")
        (f "org.gnome.Nautilus")
        (f "com.saivert.pwvucontrol")
        (f "io.github.kaii_lb.Overskride")
        (f "nm-connection-editor")
        (f "blueberry.py")
        (f "org.gnome.Settings")
        (f "org.gnome.design.Palette")
        (f "Color Picker")
        (f "xdg-desktop-portal")
        (f "xdg-desktop-portal-gnome")
        (f "xdg-desktop-portal-gtk")
        (f "transmission-remote-gtk")
        (f "com.github.Aylur.ags")

        (f "com.github.neithern.g4music")
        (f "1Password")

        # Float messaging apps
        (f "de.schmidhuberj.Flare")
        (f "signal")
        (f "app.drey.PaperPlane")
        (f "org.telegram.desktop")
        (f "im.dino.Dino")
        (f "vesktop")
        (f "wasistlos")
        (f "Slack")

        # Float launchers (steam, lutris)
        (f "steam")
        (f "lutris")

        "stayfocused,class:^(1Password)$"
        "pin,class:^(com.github.neithern.g4music)$"
        "size 75%,class:^(com.github.neithern.g4music)$"
        "stayfocused,class:^(com.github.neithern.g4music)$"
        "center,class:^(com.github.neithern.g4music)$"
        "dimaround,class:^(com.github.neithern.g4music)$"
      ];

      bind = let
        binding = mod: cmd: key: arg: "${mod}, ${key}, ${cmd}, ${arg}";
        mvfocus = binding "SUPER" "movefocus";
        ws = binding "SUPER" "workspace";
        resizeactive = binding "SUPER SHIFT" "resizeactive";
        mvactive = binding "SUPER ALT" "moveactive";
        mvtows = binding "SUPER SHIFT" "movetoworkspace";
        e = "exec, ${ags} -b hypr";
        popup_rules = "[float;pin;size 75%;stayfocused;center;dimaround]";

        popup_script = cmd: name:
          pkgs.writeShellScript "${name}-popup-script" ''
            if ${hyprctl} activewindow | ${pkgs.gnused}/bin/sed '/pinned: 1/q1' --quiet; then # If no window pinned, run normally
              ${hyprctl} dispatch exec "${popup_rules} ${cmd}"; exit 0;
            fi

            if ${hyprctl} activewindow | ${pkgs.gnused}/bin/sed '/${name}/q1' --quiet; then # If window other than ours is pinned
              ${hyprctl} dispatch killactive;
              ${hyprctl} dispatch exec "${popup_rules} ${cmd}"; exit 0; # Replace the pinned window with ours
            else
              ${hyprctl} dispatch killactive; # If our window is pinned, get rid of it
            fi;
          '';

        popup_rules_loose = "[float; size 65%; center]";
        arr = [1 2 3 4 5 6 7 8 9];
        systemd-run = "${pkgs.systemd}/bin/systemd-run --user --slice=app.slice --no-block --collect --scope";

        # "Task Manager" menu
        topPopup = popup_script "${pkgs.kitty}/bin/kitty --name 'Task Manager' --class 'btop' -- ${pkgs.btop}/bin/btop" "title: Task Manager";
        termPopup = popup_script "${systemd-run} ${pkgs.kitty}/bin/kitty -T 'Terminal (Quick)'" "title: Terminal (Quick)";
        termPopupSession = popup_script "${pkgs.kitty}/bin/kitty -T 'Terminal (session.slice)'" "title: Terminal (session.slice)";

        opPopup = popup_script "${systemd-run} ${pkgs._1password-gui}/bin/1password" "class: 1Password";

        musicPopup = popup_script "${systemd-run} ${pkgs.g4music}/bin/g4music" "class: com.github.neithern.g4music";
      in
        [
          "SUPER, R,       ${e} -t launcher"
          "SUPER, Tab,     ${e} -t overview"
          ",XF86PowerOff,  ${e} -t powermenu"
          "SUPER,O,        ${e} -r 'recorder.start()'"
          "SUPER SHIFT,P,  ${e} -r 'recorder.screenshot()'"
          "SUPER,P,        ${e} -r 'recorder.screenshot(true)'"
          "SUPER, E,       ${e} -t datemenu"
          # "SUPER, Return, exec, xterm" # xterm is a symlink, not actually xterm

          "SUPER, Q, exec, ${systemd-run} ${pkgs.kitty}/bin/kitty"

          "SUPER SHIFT, Q, execr, ${termPopup}" # Kitty popup
          "SUPER CTRL SHIFT, Q, execr, ${termPopupSession}" # Kitty popup in session.slice
          "SUPER, S, exec, ${systemd-run} ${pkgs.g4music}/bin/g4music"
          "SUPER, G, exec, ${systemd-run} ${pkgs.nautilus}/bin/nautilus"
          "SUPER, T, exec, ${systemd-run} ${pkgs._1password-gui}/bin/1password"

          "SUPER SHIFT, W, execr, ${topPopup}" # "task manager" menu

          # For debugging, use to find findow rules of current window
          "SUPER ALT, W, execr, ${hyprctl} activewindow > /home/waltmck/winrules"

          # SUPER, Tab, focuscurrentorlast"
          "CTRL ALT, Delete, exit"
          "CTRL ALT, Backspace, exit"
          "SUPER, D, killactive"
          "SUPER, F, togglefloating"
          "SUPER SHIFT, A, fullscreen"
          "SUPER, A, fullscreenstate"
          "SUPER, V, togglesplit"
          "SUPER, C, swapsplit"

          (mvfocus "k" "u")
          (mvfocus "j" "d")
          (mvfocus "l" "r")
          (mvfocus "h" "l")
          (ws "left" "e-1")
          (ws "right" "e+1")
          (mvtows "left" "e-1")
          (mvtows "right" "e+1")
          # (resizeactive "k" "0 -20")
          # (resizeactive "j" "0 20")
          # (resizeactive "l" "20 0")
          # (resizeactive "h" "-20 0")
          (mvactive "k" "0 -20")
          (mvactive "j" "0 20")
          (mvactive "l" "20 0")
          (mvactive "h" "-20 0")
        ]
        ++ (map (i: ws (toString i) (toString i)) arr)
        ++ (map (i: mvtows (toString i) (toString i)) arr);

      bindle = [
        ",XF86MonBrightnessUp,   exec, ${brightnessctl} set +5%"
        ",XF86MonBrightnessDown, exec, ${brightnessctl} set  5%-"
        ",XF86KbdBrightnessUp,   exec, ${brightnessctl} -d kbd_backlight set +5%"
        ",XF86KbdBrightnessDown, exec, ${brightnessctl} -d kbd_backlight set  5%-"
        "SHIFT,XF86MonBrightnessUp, exec, ${brightnessctl} -d kbd_backlight set +5%"
        "SHIFT,XF86MonBrightnessDown, exec, ${brightnessctl} -d kbd_backlight set 5%-"
        ",XF86AudioRaiseVolume,  exec, ${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,  exec, ${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute,         exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];

      binde = [
        "SUPER SHIFT, k, resizeactive, 0 -20"
        "SUPER SHIFT, j, resizeactive, 0 20"
        "SUPER SHIFT, l, resizeactive, 20 0"
        "SUPER SHIFT, h, resizeactive, -20 0"
      ];

      bindl = [
        # Implement media keys for desktop keyboard
        ",Print,            exec,  ${playerctl} previous"
        ",Scroll_Lock,      exec,  ${playerctl} play-pause"
        ",Pause,            exec,  ${playerctl} next"
        ",XF86Calculator,   exec,  ${playerctl} stop"

        # Regular media keys
        ",XF86AudioPlay,    exec, ${playerctl} play-pause"
        ",XF86AudioStop,    exec, ${playerctl} pause"
        ",XF86AudioPause,   exec, ${playerctl} pause"
        ",XF86AudioPrev,    exec, ${playerctl} previous"
        ",XF86AudioNext,    exec, ${playerctl} next"
        ",XF86AudioMicMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        "SHIFT,XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

        "SHIFT,XF86AudioPlay,    exec, ${playerctl} stop"
        "SHIFT,XF86AudioPrev,   exec, ${playerctl} position 2-"
        "SHIFT,XF86AudioNext,    exec, ${playerctl} position 2+"
      ];

      bindm = [
        "SUPER SHIFT, mouse:272, resizewindow"
        "SUPER, mouse:272, movewindow"
      ];

      decoration = {
        shadow = {
          enabled = true;
          range = 8;
          render_power = 2;

          color = "rgba(00000044)";
        };

        dim_inactive = false;

        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          new_optimizations = "on";
          noise = 0.01;
          contrast = 0.9;
          brightness = 0.8;
          popups = true;
        };

        rounding = 11;
      };

      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 5, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      plugin = {
        hyprbars = {
          bar_color = "rgb(2a2a2a)";
          bar_height = 28;
          col_text = "rgba(ffffffdd)";
          bar_text_size = 11;
          bar_text_font = "Ubuntu Nerd Font";

          buttons = {
            button_size = 0;
            "col.maximize" = "rgba(ffffff11)";
            "col.close" = "rgba(ff111133)";
          };
        };
      };
    };
  };

  # Persist crash logs
  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".cache/hyprland"
      ".hyprland"
    ];
  };

  environment.persistence."/nix/state" = {
    # Historical power information
    directories = ["/var/lib/upower"];
  };
}
