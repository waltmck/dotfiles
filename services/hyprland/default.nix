{
  pkgs,
  inputs,
  config,
  asztal,
  system,
  ...
}: {
  imports = [
    ./theme.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./hyprpaper.nix
  ];

  environment.enableDebugInfo = true;

  services.xserver.displayManager.startx.enable = true;

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  security = {
    polkit.enable = true;
    pam.services.ags = {};
  };

  environment.systemPackages = with pkgs;
  with gnome; [
    gnome.adwaita-icon-theme
    loupe
    adwaita-icon-theme
    wl-gammactl
    wl-clipboard
    wayshot
    pavucontrol
    brightnessctl
    inputs.hyprlock.packages.${pkgs.system}.default
    inputs.hypridle.packages.${pkgs.system}.default
    inputs.hyprpaper.packages.${pkgs.system}.default
  ];

  services = {
    gvfs.enable = true;
    # devmon.enable = true;
    # udisks2.enable = true;
    upower.enable = true; # For battery indicator
    power-profiles-daemon.enable = true;
    accounts-daemon.enable = true;
  };

  security.pam.services.greetd.enableGnomeKeyring = true;

  # This fixes the problem of the gnome-keyring not being logged into at boot
  # for reasons outside of my comprehension
  security.pam.services.sddm.enableGnomeKeyring = true;

  services.greetd = let
    session = "${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/Hyprland";
    tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
    user = "waltmck";
  in {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${session}";
        user = "${user}";
      };
      default_session = {
        command = "${tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time --cmd ${session}";
        user = "greeter";
      };
    };

    /*
      .default_session.command = pkgs.writeShellScript "greeter" ''
      export XCURSOR_THEME=Qogir
      ${asztal}/bin/greeter
    '';
    */
  };

  systemd.tmpfiles.rules = [
    "d '/var/cache/greeter' - greeter greeter - -"
  ];

  system.activationScripts.wallpaper = ''
    PATH=$PATH:${pkgs.busybox}/bin:${pkgs.jq}/bin
    CACHE="/var/cache/greeter"
    OPTS="$CACHE/options.json"
    HOME="/home/$(find /home -maxdepth 1 -printf '%f\n' | tail -n 1)"

    cp $HOME/.cache/ags/options.json $OPTS
    chown greeter:greeter $OPTS

    BG=$(cat $OPTS | jq -r '.wallpaper // "$HOME/.config/background"')
    cp $BG $CACHE/background
    chown greeter:greeter $CACHE/background
  '';

  home-manager.users.waltmck.wayland.windowManager.hyprland = let
    hyprland = inputs.hyprland.packages.${pkgs.system}.hyprland;
    plugins = inputs.hyprland-plugins.packages.${pkgs.system};

    hyprctl = "${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/hyprctl";
    hyprlock = "${inputs.hyprlock.packages.${pkgs.system}.hyprlock}/bin/Hyprlock";

    yt = pkgs.writeShellScript "yt" ''
      notify-send "Opening video" "$(wl-paste)"
      mpv "$(wl-paste)"
    '';

    playerctl = "${pkgs.playerctl}/bin/playerctl";
    brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
    wpctl = "${pkgs.wireplumber}/bin/wpctl";
  in {
    enable = true;
    package = hyprland;
    systemd.enable = true;
    xwayland.enable = true;
    # plugins = with plugins; [ hyprbars borderspp ];
    plugins = []; # [inputs.hyprspace.packages.${pkgs.system}.Hyprspace];

    settings = {
      exec-once = [
        "ags -b hypr"
        "${hyprctl} setcursor Qogir 24"
        # "transmission-gtk"
      ];

      general = {
        layout = "dwindle";
        resize_on_border = true;
        no_cursor_warps = true;

        gaps_in = 4;
        gaps_out = 8;
      };

      debug = {
        disable_logs = false;
      };

      misc = {
        disable_splash_rendering = true;
        disable_hyprland_logo = true;
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
        # no_gaps_when_only = "yes";
      };

      windowrule = let
        f = regex: "float, ^(${regex})$";
      in [
        (f "org.gnome.Calculator")
        (f "org.gnome.Nautilus")
        (f "pavucontrol")
        (f "nm-connection-editor")
        (f "blueberry.py")
        (f "org.gnome.Settings")
        (f "org.gnome.design.Palette")
        (f "Color Picker")
        (f "xdg-desktop-portal")
        (f "xdg-desktop-portal-gnome")
        (f "transmission-gtk")
        (f "com.github.Aylur.ags")

        (f "dev.alextren.Spot")
        (f "1Password")
        "stayfocused,class:^(1Password)$"
      ];

      bind = let
        binding = mod: cmd: key: arg: "${mod}, ${key}, ${cmd}, ${arg}";
        mvfocus = binding "SUPER" "movefocus";
        ws = binding "SUPER" "workspace";
        resizeactive = binding "SUPER CTRL" "resizeactive";
        mvactive = binding "SUPER ALT" "moveactive";
        mvtows = binding "SUPER SHIFT" "movetoworkspace";
        e = "exec, ags -b hypr";
        arr = [1 2 3 4 5 6 7 8 9];
      in
        [
          "CTRL SHIFT, R,  ${e} quit; ags -b hypr"
          "SUPER, R,       ${e} -t launcher"
          "SUPER, Tab,     ${e} -t overview"
          ",XF86PowerOff,  ${e} -t powermenu"
          "SUPER,O,        ${e} -r 'recorder.start()'"
          "SUPER SHIFT,P,  ${e} -r 'recorder.screenshot()'"
          "SUPER,P,        ${e} -r 'recorder.screenshot(true)'"
          # "SUPER, Return, exec, xterm" # xterm is a symlink, not actually xterm

          "SUPER, W, exec, firefox"
          "SUPER, Q, exec, blackbox"
          "SUPER, E, ${e} -t datemenu"
          "SUPER, S, exec, spot"
          "SUPER, T, exec, 1password --quick-access"

          # SUPER, Tab, focuscurrentorlast"
          "CTRL ALT, Delete, exit"
          "CTRL ALT, Backspace, exit"
          "SUPER, D, killactive"
          "SUPER, F, togglefloating"
          "SUPER, A, fullscreen"
          "SUPER SHIFT, A, fakefullscreen"
          "SUPER, V, togglesplit"

          (mvfocus "k" "u")
          (mvfocus "j" "d")
          (mvfocus "l" "r")
          (mvfocus "h" "l")
          (ws "left" "e-1")
          (ws "right" "e+1")
          (mvtows "left" "e-1")
          (mvtows "right" "e+1")
          (resizeactive "k" "0 -20")
          (resizeactive "j" "0 20")
          (resizeactive "l" "20 0")
          (resizeactive "h" "-20 0")
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
        ",XF86KbdBrightnessUp,   exec, ${brightnessctl} -d asus::kbd_backlight set +1"
        ",XF86KbdBrightnessDown, exec, ${brightnessctl} -d asus::kbd_backlight set  1-"
        ",XF86AudioRaiseVolume,  exec, ${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,  exec, ${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute,         exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];

      bindl = [
        ",XF86AudioPlay,    exec, ${playerctl} play-pause"
        ",XF86AudioStop,    exec, ${playerctl} pause"
        ",XF86AudioPause,   exec, ${playerctl} pause"
        ",XF86AudioPrev,    exec, ${playerctl} previous"
        ",XF86AudioNext,    exec, ${playerctl} next"
        ",XF86AudioMicMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];

      bindm = [
        "SUPER, mouse:273, resizewindow"
        "SUPER, mouse:272, movewindow"
      ];

      decoration = {
        drop_shadow = "yes";
        shadow_range = 8;
        shadow_render_power = 2;
        "col.shadow" = "rgba(00000044)";

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
}
