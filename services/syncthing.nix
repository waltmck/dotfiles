{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  hostname,
  ...
}: {
  environment.systemPackages = [pkgs.syncthing];

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
      options.urAccepted = -1;

      devices = {
        "walt-laptop" = {
          id = "CB64UMU-73DG62I-7SIO5XK-Z646OHX-3RRLYER-WM2VISF-F5OD7XJ-RQRG2QU";
          addresses = ["quic://walt-laptop:22000"];
        };
        "walt-cloud" = {
          id = "2VRJ6ZS-HNTNHFT-PDYVXWC-WZAXQ3J-HTYUX7O-PDZMLJO-BC2NVXF-7CATWA5";
          addresses = ["quic://walt-cloud:22000"];
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
      locations."/syncthing/".proxyPass = "http://127.0.0.1:8384/";

      # Listen for local connections
      listenAddresses = [
        "127.0.0.1"
        "[::1]"
      ];
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
