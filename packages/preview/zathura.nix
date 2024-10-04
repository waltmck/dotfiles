{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [
    pkgs.zathura
  ];

  home-manager.sharedModules = [
    {
      programs.zathura = {
        enable = true;

        options = let
          bg = "#1F1F1F";
          bg2 = "#303030";
          fg = "#FFFFFF";
          fg2 = "#A8A8A8";
        in {
          default-bg = bg;
          default-fg = fg;
          recolor = true;

          # recolor-keephue = true;

          recolor-darkcolor = fg;
          recolor-lightcolor = bg;

          selection-clipboard = "clipboard";

          inputbar-bg = bg2;
          inputbar-fg = fg;
          statusbar-bg = bg2;
          statusbar-fg = fg2;

          notification-bg = bg;
          notification-fg = fg;

          smooth-scroll = true;
        };
      };
    }
  ];
}
