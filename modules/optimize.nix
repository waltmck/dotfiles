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
            default = false;
            description = "Enable package optimization";
          };

          native = mkOption {
            type = types.bool;
            default = true;
            description = "Native build flags";
          };

          optLevel = mkOption {
            type = types.int;
            default = -1;
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
          lib.mergeAttrsList (
            lib.mapAttrsToList (name: pkg:
              lib.mkIf pkg.enable {
                "${name}" = super."${name}".overrideDerivation (old: {
                  NIX_CFLAGS_COMPILE =
                    (old.NIX_CFLAGS_COMPILE or "")
                    + (
                      if pkg.native
                      then " -march=${cfg.march}"
                      else ""
                    )
                    + (
                      if pkg.optLevel != -1
                      then " -O${pkg.optLevel}"
                      else ""
                    );
                });
              })
            cfg.packages
          )
      )
    ];
  };
}
