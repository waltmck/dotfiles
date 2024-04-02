{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
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

  # Enable the notch, and swap the fn and control keys
  boot.extraModprobeConfig = ''
    options apple_dcp show_notch = 1
    options hid_apple swap_fn_leftctrl=1
  '';

  # services.jack.jackd.enable = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}
