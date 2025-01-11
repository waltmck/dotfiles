{...}: {
  imports = [
    ./nginx.nix
    # ./headscale.nix
    ./transmission.nix
    ./jellyfin.nix
    ./arr.nix
    ./rss.nix
    ./irc.nix
    ./ntfy.nix
    ./stash.nix
    ./aria2.nix
  ];

  /*
  # Later: replace this with a mounted volume
  environment.persistence."/nix/state" = {
    directories = [
      {
        directory = "/data";
        user = "data";
        group = "data";
        mode = "777";
      }
    ];
  };
  */

  services.syncthing = {
    user = "data";
    group = "data";

    dataDir = "/data/syncthing";
    configDir = "/data/config/syncthing";
  };
}
