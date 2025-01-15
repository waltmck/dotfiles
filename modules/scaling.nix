{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) types;
  inherit (lib.options) mkOption mkEnableOption;

  cfg = config.services.scaling;
in {
  options.services.scaling = {
    enable = mkEnableOption "scaling";

    factor = mkOption {
      type = types.str;
      default = "1.0";
      description = "Scaling factor";
    };
  };

  config = lib.mkIf cfg.enable {
    # xwayland scaling
    environment.sessionVariables.GDK_SCALE = "${cfg.factor}";
  };
}
