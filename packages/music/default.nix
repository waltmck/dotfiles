{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [pkgs.g4music];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [".cache/com.github.neithern.g4music"];
  };

  home-manager.users.waltmck.dconf.settings."com/github/neithern/g4music" = {
    "audio-sink" = "alsasink";
    "blur-mode" = 2;
    "compact-playlist" = true;
    "dark-theme" = true;
    "grid-mode" = false;
    "library-path" = ["album"];
    "monitor-changes" = true;
    "play-background" = true;
    "remote-thumbnail" = true;
  };
}
