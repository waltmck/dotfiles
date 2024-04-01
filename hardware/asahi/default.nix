{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      "${inputs.apple-silicon-support}/apple-silicon-support"
    ];

  # -- Asahi-

  hardware.bluetooth.enable = true;
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  hardware.asahi = {
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
    setupAsahiSound = true;
    withRust = true;
  };

  # services.jack.jackd.enable = true;
  
  system.stateVersion = "24.05"; # Did you read the comment?

}

