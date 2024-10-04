{
  config,
  lib,
  pkgs,
  datasets,
  ...
}: {
  boot.kernelPackages = let
    isUnstable = config.boot.zfs.package == pkgs.zfsUnstable;
    zfsCompatibleKernelPackages =
      lib.filterAttrs (
        name: kernelPackages:
          (builtins.match "linux_[0-9]+_[0-9]+" name)
          != null
          && (builtins.tryEval kernelPackages).success
          && (
            (!isUnstable && !kernelPackages.zfs.meta.broken)
            || (isUnstable && !kernelPackages.zfs_unstable.meta.broken)
          )
      )
      pkgs.linuxKernel.packages;
    latestKernelPackage = lib.last (
      lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
        builtins.attrValues zfsCompatibleKernelPackages
      )
    );
  in
    latestKernelPackage;

  boot.zfs.removeLinuxDRM = true;

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  services.sanoid = {
    enable = true;
    interval = "hourly";

    datasets = lib.mergeAttrsList (builtins.map (dataset: {
        "${dataset}" = {
          autosnap = true;
          autoprune = true;

          hourly = 2;
          daily = 10;
          monthly = 12;
          yearly = 100;
        };
      })
      datasets);
  };
}
