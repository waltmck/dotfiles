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
        newsboat = let
          icon = "io.gitlab.news_flash.NewsFlash";
          tagline = "Terminal-baed RSS reader";
        in {
          name = "Newsboat";
          genericName = tagline;
          exec = ''${pkgs.kitty}/bin/kitty --name "Newsboat" --class "${icon}" -- ${pkgs.newsboat}/bin/newsboat'';
          terminal = false;
          categories = ["Application" "Network" "Feed"];
          comment = tagline;
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
