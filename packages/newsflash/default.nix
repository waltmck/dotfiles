{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [pkgs.newsflash];

  home-manager.users.waltmck = {
    home.persistence."/nix/state/home/waltmck" = {
      directories = [
        ".local/share/news-flash" # I'm not sure why it uses both of these directories, probably a bug?
        ".local/share/news_flash"
        ".cache/news_flash"
        ".config/news-flash"
      ];
    };
  };
}
