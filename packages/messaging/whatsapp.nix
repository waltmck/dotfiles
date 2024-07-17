{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [
    pkgs.element-desktop
    pkgs.fractal
  ];

  /*
  home-manager.users.waltmck.wayland.windowManager.hyprland.settings.exec-once = [
    "${pkgs.fractal}/bin/fractal --gapplication-service" # To get background notifications
  ];
  */
  /*
  home-manager.users.waltmck = {
    xdg.desktopEntries = {
      element = {
        name = "Element";
        genericName = "Matrix Client";
        exec = "${pkgs.element-desktop-wayland}/bin/element-desktop";
        terminal = false;
        categories = ["Application" "Network" "WebBrowser"];
      };
    };
  };
  */


  environment.systemPackages = [pkgs.zapzap];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [".local/share/ZapZap"];
  };
}
