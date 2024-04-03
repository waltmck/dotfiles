{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  # -- Sound --

  sound.enable = true;
  security.rtkit.enable = true;

  /*
    services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  */

  # services.jack.jackd.enable = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}
