{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  hostname,
  ...
}: {
  services.below = {
    enable = true;

    collect = {
      ioStats = true;
    };

    dirs.store = "/var/lib/below";

    retention.time = 60*60*24*7;
  };

  environment.persistence."/nix/state".directories = [
    "/var/lib/below"
  ];
}
