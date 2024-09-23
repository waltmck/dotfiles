{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  ...
}: {
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
    pkgs.intel-gpu-tools
  ];

  services.jellyfin = {
    enable = true;
    user = "data";
    group = "data";

    dataDir = "/data/config/jellyfin";
  };

  # Hardware transcoding configuration
  boot.kernelParams = [
    "i915.enable_guc=2"
  ];

  environment.variables = {
    NEOReadDebugKeys = "1";
    OverrideGpuAddressSpace = "48";
  };

  systemd.services."jellyfin".environment = {
    NEOReadDebugKeys = "1";
    OverrideGpuAddressSpace = "48";
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Jellyfin transcode cache
  environment.persistence."/nix/state".directories = [
    {
      directory = "/var/cache/jellyfin";
      user = "data";
      group = "data";
    }
  ];

  # Intro skipper plugin requires modifying nix store contents
  # Copied from https://wiki.nixos.org/wiki/Jellyfin#Intro_Skipper_plugin
  nixpkgs.overlays = with pkgs; [
    (
      final: prev: {
        jellyfin-web = prev.jellyfin-web.overrideAttrs (finalAttrs: previousAttrs: {
          installPhase = ''
            runHook preInstall

            # this is the important line
            sed -i "s#</head>#<script src=\"configurationpage?name=skip-intro-button.js\"></script></head>#" dist/index.html

            mkdir -p $out/share
            cp -a dist $out/share/jellyfin-web

            runHook postInstall
          '';
        });
      }
    )
  ];
}
