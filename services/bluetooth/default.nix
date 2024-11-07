{
  config,
  lib,
  pkgs,
  inputs,
  hostname,
  ...
}: {
  imports = [
    "${inputs.home-manager}/nixos"
    "${inputs.impermanence}/nixos.nix"
  ];

  # bluetooth
  hardware.bluetooth = {
    enable = true;

    settings = {
      General = {
        Name = hostname;
        ControllerMode = "dual";
        FastConnectable = "true";
        Experimental = "true";

        Enable = "Source,Sink,Media,Socket";
      };
      Policy = {
        AutoEnable = "true";
      };
    };

    powerOnBoot = true;
  };

  # services.blueman.enable = true;

  environment.systemPackages = [pkgs.overskride];

  environment.persistence."/nix/state" = {
    directories = [
      "/var/lib/bluetooth" # Bluetooth connections
    ];
  };
}
