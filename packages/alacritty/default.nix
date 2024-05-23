{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  home-manager.users.waltmck = {
    home = {
      sessionVariables.TERMINAL = "${pkgs.alacritty}/bin/alacritty";
    };

    programs.alacritty = {
      enable = true;
      package = pkgs.alacritty;

      settings = {
        shell.program = "${pkgs.zsh}/bin/zsh";
        window = {
          decorations = "None";
          title = "Terminal";
        };

        scrolling = {
          history = 10000;
          multiplier = 3;
        };

        font = {
          normal = {
            family = "CaskaydiaCove Nerd Font";
            style = "Regular";
          };
          bold = {
            family = "CaskaydiaCove Nerd Font";
            style = "Bold";
          };
          italic = {
            family = "CaskaydiaCove Nerd Font";
            style = "Italic";
          };
          size = 12;
        };

        colors = {
          # Using gruvbox theme
          normal = {
            black = "#282828";
            red = "#cc241d";
            green = "#98971a";
            yellow = "#d79921";
            blue = "#458588";
            magenta = "#b16286";
            cyan = "#689d6a";
            white = "#a89984";
          };
          bright = {
            black = "#928374";
            red = "#fb4934";
            green = "#b8bb26";
            yellow = "#fabd2f";
            blue = "#83a598";
            magenta = "#d3869b";
            cyan = "#8ec07c";
            white = "#ebdbb2";
          };
        };
      };
    };
  };
}
