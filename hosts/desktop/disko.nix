{
  disko.devices = {
    disk = {
      # M.2 boot drive
      boot = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_PC_SN740_SDDPNQD-256G-1006_23235U800101";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "100%";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
          };
        };
      };

      # First U.2 drive
      one = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-INTEL_SSDPF2KX038TZ_PHAC0501001K3P8AGN";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          };
        };
      };

      # Second U.2 drive
      two = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-INTEL_SSDPF2KX038TZ_PHAC128200313P8AGN";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          };
        };
      };
    };

    zpool = {
      rpool = {
        type = "zpool";
        mode = "mirror";
      };
    };
  };
}
