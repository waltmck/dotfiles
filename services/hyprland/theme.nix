{
  pkgs,
  inputs,
  config,
  system,
  ...
}: {
  imports = [
    inputs.nix-colors.homeManagerModules.default
  ];

  # kvantum qt theme engine, which can be configured with kvantummanager
  environment.systemPackages = [
    pkgs.libsForQt5.qtstyleplugin-kvantum
  ];

  home-manager.users.waltmck = let
    nerdfonts = pkgs.nerdfonts.override {
      fonts = [
        "Ubuntu"
        "UbuntuMono"
        "CascadiaCode"
        "FantasqueSansMono"
        "FiraCode"
        "Mononoki"
      ];
    };

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    font = {
      name = "Ubuntu Nerd Font";
      package = nerdfonts;
    };
    cursorTheme = {
      name = "Qogir";
      size = 24;
      package = pkgs.qogir-icon-theme;
    };
    iconTheme = {
      name = "MoreWaita";
      package = pkgs.morewaita-icon-theme;
    };
  in {
    home = {
      packages = with pkgs; [
        cantarell-fonts
        font-awesome
        theme.package
        font.package
        cursorTheme.package
        iconTheme.package
        gnome.adwaita-icon-theme
        papirus-icon-theme
      ];
      sessionVariables = {
        XCURSOR_THEME = cursorTheme.name;
        XCURSOR_SIZE = "${toString cursorTheme.size}";
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
      inherit font cursorTheme iconTheme;
      theme.name = theme.name;
      enable = true;
      gtk3.extraCss = ''
        headerbar, .titlebar,
        .csd:not(.popup):not(tooltip):not(messagedialog) decoration{
          border-radius: 0;
        }
      '';
    };

    #environment.variables = {
    #  # This will become a global environment variable
    #  "QT_STYLE_OVERRIDE" = "kvantum";
    #};

    qt = {
      enable = true;
      platformTheme.name = "qtct";
      style.name = "kvantum";
    };

    /*
    xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
      General.theme = "KvLibadwaitaDark";
    };
    */

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
  };

  colorScheme = inputs.nix-colors.colorSchemes."gruvbox-dark-hard";
}
