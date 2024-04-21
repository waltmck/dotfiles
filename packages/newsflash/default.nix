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
      files = [".cache/news_flash/HSTS/hsts-storage.sqlite"];
    };
  };
}
