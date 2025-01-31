{
  pkgs,
  inputs,
  config,
  system,
  ...
}: let
  nerdfonts = pkgs.nerdfonts.override {
    fonts = [
      "Ubuntu"
      "UbuntuMono"
      "CascadiaCode"
      "FantasqueSansMono"
      "FiraCode"
      "Mononoki"
      "Iosevka"
    ];
  };

  theme = {
    name = "adw-gtk3-dark";
    package = pkgs.adw-gtk3;
  };
  font = {
    name = "Ubuntu Nerd Font";
    package = pkgs.nerd-fonts.ubuntu;
  };
  cursorTheme = {
    name = "Qogir";
    # Temporary fix for GTK4 cursor bug, see https://bbs.archlinux.org/viewtopic.php?id=299624
    # Once a fix is merge, revert to 24
    size = 32;
    package = pkgs.qogir-icon-theme;
  };
  iconTheme = {
    name = "MoreWaita";
    package = pkgs.morewaita-icon-theme;
  };
in {
  # kvantum qt theme engine, which can be configured with kvantummanager
  environment.systemPackages = [
    pkgs.libsForQt5.qtstyleplugin-kvantum
    pkgs.xdg-desktop-portal-gtk
  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs.nerd-fonts; [
      ubuntu
      ubuntu-mono
      caskaydia-cove
      caskaydia-mono
      fantasque-sans-mono
      fira-code
      fira-mono
      mononoki
      iosevka
      iosevka-term
      iosevka-term-slab
    ];
  };

  home-manager.users.waltmck = {
    home = {
      packages = with pkgs; [
        cantarell-fonts
        font-awesome
        theme.package
        font.package
        cursorTheme.package
        iconTheme.package
        adwaita-icon-theme
        papirus-icon-theme
      ];
      sessionVariables = {
        # XCURSOR_THEME = cursorTheme.name;
        # XCURSOR_SIZE = "${toString cursorTheme.size}";
      };
      pointerCursor =
        cursorTheme
        // {
          gtk.enable = true;
        };
      file = {
        ".local/share/themes/${theme.name}" = {
          source = "${theme.package}/share/themes/${theme.name}";
        };
        ".config/gtk-4.0/gtk.css".text = ''
          window.messagedialog .response-area > button,
          window.dialog.message .dialog-action-area > button,
          .background.csd{
            border-radius: 0;
          }
        '';
      };
    };

    fonts.fontconfig.enable = true;

    gtk = {
      inherit font iconTheme;
      theme.name = theme.name;
      enable = true;
      gtk3.extraCss = ''
        headerbar, .titlebar,
        .csd:not(.popup):not(tooltip):not(messagedialog) decoration{
          border-radius: 0;
        }
      '';
    };

    dconf.settings = {
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };

    /*
    qt = {
      enable = true;
      platformTheme.name = "qtct";
      style.name = "kvantum";
    };
    */

    /*
    xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
      General.theme = "KvLibadwaitaDark";
    };
    */

    /*
    xdg.configFile = {
      "Kvantum/KvLibadwaita" = {
        source = "${./kvantum-theme/KvLibadwaita}";
        recursive = true;
      };
      "Kvantum/Colors" = {
        source = "${./kvantum-theme/Colors}";
        recursive = true;
      };
      "Kvantum/kvantum.kvconfig".text = "[General]\ntheme=KvLibadwaitaDark";
    };
    */
  };

  /*
  environment.variables = {
    "QT_SCALE_FACTOR" = "0.7";
    "QT_QPA_PLATFORM" = "wayland";
    "QT_WAYLAND_DISABLE_WINDOWDECORATION" = 1;
    "QT_QPA_PLATFORMTHEME" = "qt5ct";

    "GDK_BACKEND" = "wayland";
    "SDL_VIDEODRIVER" = "wayland";
    "CLUTTER_BACKEND" = "wayland";
  };
  */
}
