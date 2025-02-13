# To be included in the configuration of machines used to build robotnix
{lib, ...}: let
  mirrors = {
    "https://android.googlesource.com" = "/cache/mirror";
    # "https://github.com/LineageOS" = "/mnt/cache/lineageos/LineageOS";
  };
in {
  nix.envVars.ROBOTNIX_GIT_MIRRORS = lib.concatStringsSep "|" (lib.mapAttrsToList (local: remote: "${local}=${remote}") mirrors);

  # Also add local mirrors to nix sandbox exceptions
  nix.settings.extra-sandbox-paths = lib.attrValues mirrors;
}
