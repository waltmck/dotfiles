{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    transmission-remote-gtk # Official client
    # fragments # Unofficial client
  ];

  home-manager.users.waltmck = {
    /*
    dconf.settings."de/haeckerfelix/Fragments" = {
      client-last-connection = "8fdc9e5d-efb7-4b76-8345-58eff0039cc9";
    };
    # This throws an error on read only filesystem. Will just use transmission-remote-gtk instead.
    home.file.".config/fragments/connections.conf" = {
      enable = true;
      text = ''
        [8fdc9e5d-efb7-4b76-8345-58eff0039cc9]
        title=walt-cloud
        address=http://walt-cloud:9091/transmission/rpc
      '';
    };
    */

    home.file.".config/transmission-remote-gtk/config.json" = {
      enable = true;

      source = ./config.json;
    };
  };
}
