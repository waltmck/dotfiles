{
  pkgs,
  inputs,
  config,
  lib,
  headless,
  ...
}: {
  home-manager.users.waltmck = {
    xdg.userDirs.enable = true;

    xdg.desktopEntries = {
      "org.gnome.Settings" = {
        name = "Settings";
        comment = "Gnome Control Center";
        icon = "org.gnome.Settings";
        exec = "env XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome-control-center}/bin/gnome-control-center";
        categories = ["X-Preferences"];
        terminal = false;
      };

      "lf" = {
        name = "lf";
        noDisplay = true;
      };
    };
  };

  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    EDITOR = "vim";
    TERMINAL = "${pkgs.kitty}/bin/kitty";
    OPENER = "xdg-open";

    # Not officially in the specification
    XDG_BIN_HOME = "$HOME/.local/bin";
    PATH = [
      "${XDG_BIN_HOME}"
    ];
  };

  xdg.mime = {
    enable = true;
    defaultApplications = (
      let
        browser = "firefox.desktop";
        pdf = "org.pwmt.zathura.desktop"; # "org.gnome.Papers.desktop";
        video = "io.github.celluloid_player.Celluloid.desktop";
        image = "org.gnome.Loupe.desktop";
        latex = "org.cvfosammmm.Setzer.desktop";
        text = "neovide.desktop";
        code = "neovide.desktop";

        fileformats = import ./fileformats.nix;
        types = program: type:
          builtins.listToAttrs (builtins.map
            (x: {
              name = x;
              value = program;
            })
            type);
      in
        lib.zipAttrsWith (_: values: values) [
          (types image fileformats.image)
          (types browser fileformats.browser)
          (types video fileformats.audiovideo)
          (types text fileformats.text)
          (types code fileformats.code)
          {
            "application/pdf" = pdf;
            "application/postscript" = pdf;
            "image/vnd.djvu" = pdf;
            "application/vnd.ms-xpsdocument" = pdf;
            "application/tex" = latex;
          }
        ]
    );
  };
}
