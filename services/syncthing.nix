{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  hostname,
  ...
}: let
  # TODO figure out why quic is broken
  protocol = "tcp";
in {
  environment.systemPackages = [pkgs.syncthing];

  # Recommended for quic, to increase performance. See:
  # https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
  boot.kernel.sysctl."net.core.rmem_max" = 7500000;
  boot.kernel.sysctl."net.core.wmem_max" = 7500000;

  services.syncthing = {
    enable = true;
    user = lib.mkDefault "waltmck";
    dataDir = lib.mkDefault "/home/waltmck/sync";
    configDir = lib.mkDefault "/home/waltmck/.config/syncthing";
    overrideDevices = true;

    # Configure folders manually until we get
    # support for declarative configuration of
    # untrusted nodes
    overrideFolders = false;

    # Enable gui remote access only if headless
    guiAddress =
      if headless
      then "0.0.0.0:8384"
      else "127.0.0.1:8384";

    settings = {
      options = {
        urAccepted = -1;
        relaysEnabled = false; # Use Tailscale for direct connections
      };

      devices = {
        "walt-laptop" = {
          id = "CB64UMU-73DG62I-7SIO5XK-Z646OHX-3RRLYER-WM2VISF-F5OD7XJ-RQRG2QU";
          addresses = ["${protocol}://walt-laptop:22000"];
        };
        "walt-cloud" = {
          id = "LYZMZD4-QGMHQX2-NVC2A4A-3QJFKWQ-ICXOARZ-F4OVURU-D6ZTVFG-BH65EQA";
          addresses = ["${protocol}://walt-cloud:22000"];
        };
        "walt-phone" = {
          id = "AB5YGZ7-FA6ANNK-DJ7LS5W-DZF5EK3-FIYY4L7-B5O3E2Z-H4MWQRR-TEUA3QI";
          addresses = ["${protocol}://walt-phone:22000"];
        };
        "walt-reader" = {
          id = "DAH6HPS-GM43HSW-2P6OPKY-HQXKN5F-A37LZ2I-YCAL2DI-2M6Z4DU-QSNDXAI";
          addresses = ["${protocol}://walt-reader:22000"];
        };
      };
    };
  };

  environment.persistence."/nix/state" = {
    directories = [
      {
        directory = "/home/waltmck/.config/syncthing";
        user = "waltmck";
        group = "syncthing";
      }
    ];
  };

  services.nginx = {
    enable = true;

    virtualHosts."${hostname}" = {
      locations."/syncthing/" = {
        proxyPass = "http://127.0.0.1:8384/";

        # If not headless, restrict to local connections
        extraConfig =
          if headless
          then ''
            allow 100.64.0.0/24;
            allow 127.0.0.0/8;
            allow ::1/128;
            deny  all;
          ''
          else ''
            allow 127.0.0.0/8;
            allow ::1/128;
            deny  all;
          '';
      };
    };
  };

  /*
  home-manager.users.waltmck.services.syncthing = {
    tray = {
      enable = !headless;
      package = pkgs.syncthingtray;
    };
  };

  # Workaround for Failed to restart syncthingtray.service: Unit tray.target not found.
  # - https://github.com/nix-community/home-manager/issues/2064
  systemd.user.targets.tray = lib.mkIf (!headless) {
    unitConfig = {
      Description = "Home Manager System Tray";
      Requires = ["graphical-session-pre.target"];
    };
  };
  */

  # networking.firewall.allowedTCPPorts = [22000];
  # networking.firewall.allowedUDPPorts = [22000 21027];
}
