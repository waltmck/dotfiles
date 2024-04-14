{
  config,
  lib,
  pkgs,
  inputs,
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
        Name = "walt-laptop";
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

  services.blueman.enable = true;

  environment.persistence."/nix/state" = {
    directories = [
      "/var/lib/bluetooth" # Bluetooth connections
    ];
  };
}
