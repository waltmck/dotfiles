{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [pkgs.newsboat];

  home-manager.sharedModules = [
    {
      xdg.desktopEntries = {
        newsboat = {
          name = "Newsboat";
          genericName = "Terminal-based RSS reader";
          exec = ''${pkgs.kitty}/bin/kitty --name "Newsboat" --class "io.gitlab.news_flash.NewsFlash" -- ${pkgs.newsboat}/bin/newsboat'';
          terminal = false;
          categories = ["Application" "Network" "Feed"];
        };
      };

      programs.newsboat = {
        enable = true;

        extraConfig = ''
          urls-source "miniflux"
          miniflux-url "http://walt-cloud/rss"

          miniflux-login "waltmck"
          miniflux-password "password"
        '';
      };
    }
  ];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".local/share/newsboat"
    ];
  };
}
