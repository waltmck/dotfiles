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
  # environment.sessionVariables.GDK_SCALE = "1.5";
  services.scaling = {
    enable = true;
    factor = "1.5";
  };

  home-manager.users.waltmck.programs.firefox.profiles.default.settings = {
    "mousewheel.default.delta_multiplier_y" = 160;
    "mousewheel.default.delta_multiplier_x" = 80;
  };

  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    # AMD gpu tuning
    corectrl
    lact
    amdgpu_top

    # Razer
    polychromatic
    openrazer-daemon
  ];

  hardware.graphics.extraPackages = with pkgs; [
    amdvlk

    # OpenCL
    rocmPackages.clr.icd
  ];

  boot.initrd.availableKernelModules = ["amdgpu" "radeon"];
  services.xserver.videoDrivers = ["amdgpu"];

  services.ollama = {
    loadModels = [
      "llama3.3"
    ];
    environmentVariables = {
      HCC_AMDGPU_TARGET = "gfx1100"; # used to be necessary, but doesn't seem to anymore
    };
    rocmOverrideGfx = "11.0.0";

    models = "/games/ollama";

    acceleration = "rocm";

    user = "ollama";
    group = "ollama";
  };

  # Vulkan renderer is buggy
  environment.sessionVariables.GSK_RENDERER = "ngl";

  # Don't like hyprsunset on my monitor
  systemd.user.services.hyprsunset.enable = false;

  # Set static time zone and location since we are a desktop
  time.timeZone = "America/New_York";

  services.geoclue2 = {
    enable = true;
    enableDemoAgent = true;

    geoProviderUrl = "";
  };

  location.latitude = 42.365518;
  location.longitude = -71.108455;
  location.provider = "manual";

  environment.etc = {
    "geolocation".text = ''
      42.365518   # latitude
      -71.108455  # longitude
      16           # altitude
      1.83         # accuracy radius
    '';
    "geoclue/conf.d/00-config.conf".text = ''
      [static-source]
      enable=true
    '';
  };

  # Razer mouse. For now, openrazer does not support the mouse dock pro
  # See https://github.com/openrazer/openrazer/issues/2060
  hardware.openrazer = {
    enable = true;
    users = ["waltmck"];
  };

  users.groups.plugdev = {};
  users.users.waltmck.extraGroups = ["plugdev"];

  # Let's rip some threads
  nix.settings.max-jobs = 48;

  # For debugging
  boot.kernelParams = [
    # Threadrippers do not support s2idle
    "mem_sleep_default=deep"

    # Increase queue size for networking since we have a lot of memory and a 10Gb card
    "net.core.netdev_max_backlog = 16384"

    "splash"
    "nowatchdog" # For power efficiency, should only do this if you have a physical power button

    # Only critical notifications during boot
    "quiet"
    "loglevel=3"
    "rd.udev.log_level=3"
    "systemd.show_status=auto"
    "rd.systemd.show_status=auto"

    # Performance
    "init_on_alloc=0"
  ];

  boot.crashDump.enable = true;
}
