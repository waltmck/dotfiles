{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  /* 
  home-manager.users.waltmck.dconf.settings."org/gnome/nautilus/preferences" = {
    "default-folder-viewer" = "list-view";
    "search-filter-time-type" = "last_modified";
  };
  */
  home-manager.users.waltmck.imports = [./home.nix];
}
