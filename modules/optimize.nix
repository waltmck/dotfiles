{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) types;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption mkEnableOption;

  cfg = config.services.optimize;
in {
  options.services.optimize = {
    enable = mkEnableOption "optimize";

    march = mkOption {
      type = types.string;
      default = "native";
      description = "Arcitecture passed to -march=";
    };

    packages = mkOption {
      default = {};

      type = types.attrsOf (types.submodule ({name, ...}: {
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Enable package optimization";
          };

          native = mkOption {
            type = types.bool;
            default = true;
            description = "Native build flags";
          };

          o = mkOption {
            type = types.nullOr types.string;
            default = null;
            description = "Compiler optimization level";
          };
        };
      }));
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (
        self: super:
          lib.concatMapAttrs (name: pkg:
            lib.optionalAttrs pkg.enable {
              "${name}" = super."${name}".overrideDerivation (old: {
                NIX_CFLAGS_COMPILE =
                  (old.NIX_CFLAGS_COMPILE or "")
                  + (
                    if pkg.native
                    then " -march=${cfg.march}"
                    else ""
                  )
                  + (
                    if pkg.o != null
                    then " -O${pkg.o}"
                    else ""
                  );
              });
            })
          cfg.packages
      )
    ];
  };
}
