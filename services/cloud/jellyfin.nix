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

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      onevpl-intel-gpu
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
}
