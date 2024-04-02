{pkgs, ...}: {
  imports = [
    ./config.jsonc.nix
    ./style.css.nix
  ];

  environment.systemPackages = [pkgs.waybar];

  home-manager.users.waltmck = {
    programs.waybar = {
      enable = true;
      package = pkgs.waybar.override (oldAttrs: {pulseSupport = true;});
    };
    home.file.".config/hypr/per-app/waybar.conf" = {
      text = ''
        exec-once = ${pkgs.waybar}/bin/waybar
      '';
    };
  };
}
