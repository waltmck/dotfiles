{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  # Audio uses PipeWire/pipewire-pulse with WirePlumber

  # Just for pactl
  # environment.systemPackages = [pkgs.pulseaudio];

  # sound.enable = true;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber = {
      enable = true;
    };
  };

  # If you try to run this, it fails with
  # Error installing file '/.local/state/wireplumber/restore-stream' outside $HOME

  #environment.persistence."/nix/state".users.waltmck = {
  #  files = [
  #    "/.local/state/wireplumber/restore-stream" # Persist volume
  #  ];
  #};
}
