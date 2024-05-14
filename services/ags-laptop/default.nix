{
  config,
  lib,
  pkgs,
  inputs,
  system,
  asztal,
  ...
}: {
  home-manager.users.waltmck = {
    imports = [
      inputs.ags.homeManagerModules.default
      inputs.astal.homeManagerModules.default
    ];

    home.packages = with pkgs; [
      asztal
      bun
      dart-sass
      fd
      brightnessctl
      # swww
      # inputs.matugen.packages.${system}.default
      slurp
      wf-recorder
      wl-clipboard
      wayshot
      swappy
      hyprpicker
      pavucontrol
      networkmanager
      gtk3
    ];

    programs.astal = {
      enable = true;
      extraPackages = with pkgs; [
        libadwaita
      ];
    };

    programs.ags = {
      enable = true;
      configDir = ./ags;
      # extraPackages = with pkgs; [
      #   accountsservice
      # ];

      package = inputs.ags.packages.${pkgs.system}.default;
    };
  };

  environment.persistence."/nix/state".users.waltmck = {
    directories = [".cache/ags"];
  };

  /*
  systemd.user.services.ags = {
    description = "Aylur's Gnome Widgets";
    documentation = ["https://aylur.github.io/ags-docs"];
    partOf = ["hyprland-session.target"];
    after = ["graphical-session.target"];
    wantedBy = ["graphical-session.target"];
    Requires = ["hyprland-session.target"];

    unitConfig = {
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    serviceConfig = {
      Type = "simple";
      ExecStart = "${inputs.ags.packages.${pkgs.system}.default}/bin/ags -b hypr";
      Restart = "on-failure";
    };
  };
  */
}
