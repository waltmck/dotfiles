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
      directories = [".cache/news_flash"];
    };
  };
}
