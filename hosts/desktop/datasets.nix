{
  disko.devices.zpool.rpool = {
    options = {
      ashift = "13";
    };
    rootFsOptions = {
      mountpoint = "none";
      canmount = "off";
      "com.sun:auto-snapshot" = "false";
      xattr = "sa";
      acltype = "posixacl";
      atime = "off";
      dnodesize = "auto";

      # I am not enabling autotrim since I will do scheduled trims
    };

    datasets = {
      # --- Pool for immutable system ---
      sys = {
        type = "zfs_fs";
        options = {
          mountpoint = "none";
          canmount = "off";
        };
      };
      "sys/nix" = {
        type = "zfs_fs";

        options = {
          mountpoint = "legacy";
          # Enable dedup (mostly impacts write speed which is acceptable, significant space savings)
          dedup = "on";
        };

        mountpoint = "/nix";
      };

      # --- Reserved pool for performance ---
      reserved = {
        type = "zfs_fs";
        options = {
          mountpoint = "none";
          canmount = "off";
          reservation = "350M";
        };
      };

      # --- Pool for encrypted state ---
      enc = {
        type = "zfs_fs";
        options = {
          mountpoint = "none";
          canmount = "off";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
        };
      };

      # For persistent data (enable snapshots)
      "enc/state" = {
        type = "zfs_fs";
        options = {
          mountpoint = "none";
          canmount = "off";
          "com.sun:auto-snapshot" = "true";
        };
      };

      "enc/state/root" = {
        type = "zfs_fs";
        options = {
          mountpoint = "legacy";
          canmount = "on";
        };

        mountpoint = "/";
      };

      "enc/docker" = {
        type = "zfs_fs";
        options = {
          mountpoint = "/var/lib/docker";
          dedup = "on";
        };
      };

      "enc/tmp" = {
        type = "zfs_fs";
        options = {
          mountpoint = "legacy";
          canmount = "on";
        };
        mountpoint = "/tmp";
      };

      "enc/log" = {
        type = "zfs_fs";
        options = {
          mountpoint = "legacy";
          canmount = "on";
        };
        mountpoint = "/var/log";
      };
    };
  };
}
