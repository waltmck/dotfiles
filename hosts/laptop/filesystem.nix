{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  # -- Filesystem and Boot Stuff --

  boot = {
    initrd = {
      systemd.enable = true;
      kernelModules = ["usb_storage" "usbhid" "dm-crypt" "xts" "encrypted_keys" "ext4" "dm-snapshot"];

      luks.devices."encrypted" = {
        bypassWorkqueues = true;
        allowDiscards = true;
      };
    };

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 50; # Number of generations which are kept in the bootloader, to prevent initrd from running out of space
      };
      efi.canTouchEfiVariables = false;
      timeout = 3;
    };

    /*
    plymouth = rec {
      enable = true;
      # black_hud circle_hud cross_hud square_hud
      # circuit connect cuts_alt seal_2 seal_3
      theme = "connect";
      themePackages = with pkgs; [
        (
          adi1090x-plymouth-themes.override {
            selected_themes = [theme];
          }
        )
      ];

    };
    */

    kernelParams = [
      "splash"
      "nowatchdog" # For power efficiency, should only do this if you have a physical power button

      # Only critical notifications during boot
      "quiet"
      "loglevel=3"
      "rd.udev.log_level=3"
      "systemd.show_status=auto"
      "rd.systemd.show_status=auto"

      "init_on_alloc=0"
    ];
  };

  /*
  nixos-boot = {
    enable = true;

    # Different colors
    # bgColor.red   = 100; # 0 - 255
    # bgColor.green = 100; # 0 - 255
    # bgColor.blue  = 100; # 0 - 255

    # If you want to make sure the theme is seen when your computer starts too fast
    duration = 3.0; # in seconds
  };
  */

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=16G"
      "mode=755"
      # "noexec" This makes it really hard to build certain things (i.e. m1n1), so I am disabling it.
    ];
  };
}
