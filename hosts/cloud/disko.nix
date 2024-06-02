{
  disko.devices = {
    disk = {
      one = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            mdadm = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "raid0";
              };
            };
          };
        };
      };
      two = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            extra = {
              size = "1G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = false;
              };
            };
            mdadm = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "raid0";
              };
            };
          };
        };
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "defaults"
          "size=16G"
          "mode=755"
        ];
      };
    };
    mdadm = {
      raid0 = {
        type = "mdadm";
        level = 0;
        content = {
          type = "gpt";
          partitions.primary = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
            };
          };
        };
      };
    };
  };
  fileSystems = {
    "/".neededForBoot = true;
    #"/nix".neededForBoot = true;
    # "/boot".neededForBoot = true;
  };
}
