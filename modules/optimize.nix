{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) types;
  inherit (lib.options) mkOption mkEnableOption;

  cfg = config.services.optimize;
in {
  options.services.optimize = {
    enable = mkEnableOption "optimize";

    march = mkOption {
      type = types.str;
      default = "native";
      description = "Arcitecture passed to -march=";
    };

    kernel = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable kernel optimizations";
      };

      native = mkOption {
        type = types.bool;
        default = true;
        description = "Build kernel with native flags";
      };

      o = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Compiler optimization level";
      };
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
            type = types.nullOr types.str;
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

      # TODO kernel overlay
    ];
  };
}
