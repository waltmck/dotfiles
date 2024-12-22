{
  config,
  lib,
  pkgs,
  inputs,
  march,
  native,
  system,
  ...
}: {
  imports = [
    "${inputs.apple-silicon-support}/apple-silicon-support"
  ];

  # -- Asahi-

  hardware.graphics = {
    enable = true;
    enable32Bit = false;
    # driSupport = true;
  };

  hardware.asahi = {
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
    setupAsahiSound = true;
    withRust = true;
  };

  # Firefox DRM Support
  nixpkgs.overlays = [inputs.nixos-aarch64-widevine.overlays.default];
  environment.sessionVariables.MOZ_GMP_PATH = ["${pkgs.widevine-cdm-lacros}/gmp-widevinecdm/system-installed"];

  # Apparently this useragent causes CloudFlare to block me. Instead, you need to manually configure this in UAswitcher using the following rule under "custom mode":
  /*
  ```
    {
      "netflix.com": "Mozilla/5.0 (X11; CrOS x86_64 15633.69.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.6045.212 Safari/537.36"
    }
  ```
  */
  # home-manager.users.waltmck.programs.firefox.profiles.default.settings."general.useragent.override" = "Mozilla/5.0 (X11; CrOS aarch64 15236.80.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.5414.125 Safari/537.36"; # In order for Netflix to work it needs to think you are a chromebook. This is stupid.

  # Enable the notch, and swap the fn and control keys
  boot.extraModprobeConfig = ''
    options apple_dcp show_notch=1
    options hid_apple swap_fn_leftctrl=1
  '';

  # services.jack.jackd.enable = true;

  nix.settings.max-jobs = 2;

  # hardware.opengl.driSupport32Bit = false;

  nixpkgs.hostPlatform =
    if native
    then {
      gcc.arch = march;
      gcc.tune = march;
      inherit system;
    }
    else {
      inherit system;
    };
}
