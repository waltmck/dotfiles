{pkgs, ...}: {
  home-manager.users.waltmck.wayland.windowManager.hyprland.settings = {
    monitor = [
      # "eDP-1, 1920x1080, 0x0, 1"
      # "HDMI-A-1, 2560x1440, 1920x0, 1"
      # ",preferred,auto,1.5"
      "DP-1, 3840x2160@120, 0x0, 1.5, bitdepth, 10"
    ];

    misc.vrr = 1;

    xwayland.force_zero_scaling = true;
  };

  # Scale X11 apps
  environment.sessionVariables.GDK_SCALE = "1.5";

  home-manager.users.waltmck.programs.firefox.profiles.default.settings = {
    "mousewheel.default.delta_multiplier_y" = 160;
    "mousewheel.default.delta_multiplier_x" = 80;
  };

  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    # AMD gpu tuning
    corectrl
    lact
  ];

  hardware.graphics.extraPackages = with pkgs; [
    amdvlk
  ];

  boot.initrd.availableKernelModules = ["amdgpu" "radeon"];
  services.xserver.videoDrivers = ["amdgpu"];

  # Vulkan renderer is buggy
  environment.sessionVariables.GSK_RENDERER = "ngl";

  # Don't like hyprsunset on my monitor
  systemd.user.services.hyprsunset.enable = false;
}
