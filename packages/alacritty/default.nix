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
      };
    };
  };
}
