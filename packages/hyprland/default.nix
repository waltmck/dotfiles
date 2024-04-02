{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: {
  programs.hyprland = {
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    enable = true;
    xwayland.enable = true;
  };

  #
  #  users.users.${spaghetti.user}.packages = [pkgs.hyprland-protocols];
  home-manager.users.waltmck = {
    wayland.windowManager.hyprland = {
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;

      systemd.enable = true;
      xwayland.enable = true;
      enable = true;

      plugins = [
        # inputs.hyprland-plugins.packages.${pkgs.system}.hyprtrails # hot, but not used much in current config
        # inputs.hyprland-plugins.packages.${pkgs.system}.hyprwinwrap # throws errors, might be hy3 or lack of plugin config :)
        # inputs.hy3.packages.${pkgs.system}.hy3
      ];
      extraConfig = ''
        ${builtins.readFile ./hyprland.conf}
      '';
    };
    #
    home.file.".config/hypr/colours.conf" = {
      text = ''
        # add nix-colors below, sourced in hyprland.conf
        $c0 = rgba(${config.colorscheme.palette.base00}FF)
        $c1 = rgba(${config.colorscheme.palette.base01}FF)
        $c2 = rgba(${config.colorscheme.palette.base02}FF)
        $c3 = rgba(${config.colorscheme.palette.base03}FF)
        $c4 = rgba(${config.colorscheme.palette.base04}FF)
        $c5 = rgba(${config.colorscheme.palette.base05}FF)
        $c6 = rgba(${config.colorscheme.palette.base06}FF)
        $c7 = rgba(${config.colorscheme.palette.base07}FF)
        $c8 = rgba(${config.colorscheme.palette.base08}FF)
        $c9 = rgba(${config.colorscheme.palette.base09}FF)
        $ca = rgba(${config.colorscheme.palette.base0A}FF)
        $cb = rgba(${config.colorscheme.palette.base0B}FF)
        $cc = rgba(${config.colorscheme.palette.base0C}FF)
        $cd = rgba(${config.colorscheme.palette.base0D}FF)
        $ce = rgba(${config.colorscheme.palette.base0E}FF)
        $cf = rgba(${config.colorscheme.palette.base0F}FF)
        # testing some with transparency 99 ~ 60%
        $c099 = rgba(${config.colorscheme.palette.base00}99)
        $c199 = rgba(${config.colorscheme.palette.base01}99)
        $c299 = rgba(${config.colorscheme.palette.base02}99)
        $c399 = rgba(${config.colorscheme.palette.base03}99)
        $c499 = rgba(${config.colorscheme.palette.base04}99)
        $c599 = rgba(${config.colorscheme.palette.base05}99)
        $c699 = rgba(${config.colorscheme.palette.base06}99)
        $c799 = rgba(${config.colorscheme.palette.base07}99)
        $c899 = rgba(${config.colorscheme.palette.base08}99)
        $c999 = rgba(${config.colorscheme.palette.base09}99)
        $ca99 = rgba(${config.colorscheme.palette.base0A}99)
        $cb99 = rgba(${config.colorscheme.palette.base0B}99)
        $cc99 = rgba(${config.colorscheme.palette.base0C}99)
        $cd99 = rgba(${config.colorscheme.palette.base0D}99)
        $ce99 = rgba(${config.colorscheme.palette.base0E}99)
        $cf99 = rgba(${config.colorscheme.palette.base0F}99)
      '';
    };
    #
  };

  environment.systemPackages = with pkgs;
  with gnome; [
    gnome.adwaita-icon-theme
    loupe
    adwaita-icon-theme
    nautilus
    baobab
    gnome-text-editor
    gnome-calendar
    gnome-boxes
    gnome-system-monitor
    gnome-control-center
    gnome-weather
    gnome-calculator
    gnome-clocks
    gnome-software # for flatpak
    wl-gammactl
    wl-clipboard
    wayshot
    pavucontrol
    brightnessctl
    swww
  ];

  #
  #(mkIf (cfg.hyprpaper.enable) {
  #  # make if (hypr and hyprpaper) enabled
  #  users.users.waltmck.packages = [pkgs.hyprpaper];
  #  home-manager.users.waltmck = {
  #    home.file.".config/hypr/hyprpaper.conf" = {
  #      text = ''
  #        preload = /home/waltmck/wallpapers/1.jpg
  #        preload = /home/waltmck/wallpapers/2.jpg
  #        preload = /home/waltmck/wallpapers/3.jpg
  #        preload = /home/waltmck/wallpapers/4.jpg
  #        preload = /home/waltmck/wallpapers/5.png
  #        # ^ images must be preloaded to display
  #        wallpaper = , /home/waltmck/wallpapers/3.jpg # disabled wallpaper on boot, can set using hyprctl - want to add to agsr
  #        # ^ any display, directory/name.ext
  #        splash = false
  #        # ^ adds splash text to wallpaper when true
  #      '';
  #    };
  #    home.file.".config/hypr/per-app/hyprpaper.conf" = {
  #      text = ''
  #        exec-once = sleep 1 && hyprpaper
  #        # launch hyprpaper in per-app
  #      '';
  #    };
  #  };
  #})
  # ];
}
