These instructions are for installing NixOS with impermanence and full-disk encryption on a Apple Silicon macbook using Asahi. They were tested on an M2 Macbook Air.
## Prerequisites

These links heavily informed the below steps, and should be read and understood.
* [NixOS Apple Silicon Support (asahi) partition guide](https://github.com/tpwrules/nixos-apple-silicon/blob/main/docs/uefi-standalone.md)
* [These LUKS/systemd-boot setup instructions](https://github.com/vilvo/mxdots?tab=readme-ov-file#disk-encryption-with-systemd-boot)
* [The famous blog post on tmpfs as root](https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/)
	* In fact, I use a [tmpfs as home](https://elis.nu/blog/2020/06/nixos-tmpfs-as-home).

## Instructions

Note: the following steps are roughly correct, but may be missing some details. You should carefully review and understand the above links.

First, follow the instructions from the [above link](https://github.com/tpwrules/nixos-apple-silicon/blob/main/docs/uefi-standalone.md) to partition the disk, install the m1n1 bootloader, etc. When you get to the "Partitioning and Formatting" session, instead follow the below steps.

Create partition a root partition using all of the free space on your SSD:
```
sgdisk /dev/nvme0n1 -n 0:0 -s
```

Use `sgdisk /dev/nvme0n1 -p` to display the partition table of your disk. Find your root partition number (typically listed second to last, probably be `nvme0n1p5`). I will proceed under the assumption that it is `/dev/nvme0n1p5`. The following must be done very carefully, otherwise it could lead to unrecoverable reformatting of MacOS partitions.

Setup LUKS with a swap partition `swap` and a `/nix` partition using EXT4
```
cryptsetup luksFormat --type luks2 --sector-size 4096 /dev/nvme0n1p5
cryptsetup luksOpen /dev/nvme0n1p5 encrypted
pvcreate /dev/mapper/encrypted
vgcreate vg /dev/mapper/encrypted
lvcreate -L 64G -n swap vg
lvcreate -l '100%FREE' -n nix vg
mkfs.ext4 -L nix /dev/vg/nix
mkswap -L swap /dev/vg/swap
swapon /dev/vg/swap
```

Mount stuff
```
mount -t tmpfs none /mnt

mkdir -p /mnt/boot
mount /dev/disk/by-partuuid/`cat /proc/device-tree/chosen/asahi,efi-system-partition` /mnt/boot

mkdir -p /mnt/nix
mount /dev/disk/by-label/nix /mnt/nix
```

Initial persistent directories
```
mkdir -p /mnt/nix/state/{etc/nixos,var/log}

mount -o bind /mnt/nix/state/etc/nixos /mnt/etc/nixos
mount -o bind /mnt/nix/state/var/log /mnt/var/log
```

Generate config
```
nixos-generate-config --root /mnt

cp -r /etc/nixos/apple-silicon-support /mnt/etc/nixos/
chmod -R +w /mnt/etc/nixos/
```

asahi-specific `configuration.nix` tweaking:
```
imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Include the necessary packages and configuration for Apple Silicon support.
      ./apple-silicon-support
    ];

# Use the systemd-boot EFI boot loader.
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = false;
```

`luks`-specific tweaking:
```
# check the uuid of your partition with lsblk -f - NOTE: "encrypted" must match whatever you set with cryptsetup luksOpen
boot.initrd.luks.devices."encrypted" = {
  device = "/dev/disk/by-uuid/<uuid_of_your_/dev/nvme0n1p5>";
  bypassWorkqueues = true;
  allowDiscards = true;
};
```

Do `tmpfs`-specific tweaking:
```
fileSystems."/" = {
	device = "none";
	fsType = "tmpfs";
	options = [ "defaults" "size=64G" "mode=755" ];
  };
```

Configure users (required for tmpfs as root)
```
users.mutableUsers = false;

# Set a root password, consider using initialHashedPassword instead.
#
# To generate a hash to put in initialHashedPassword
# you can do this:
# $ nix-shell --run 'mkpasswd -m SHA-512 -s' -p mkpasswd
users.users = {
  root.initialPassword = "hunter1";

  waltmck = {
    # Change this to initialPasswordHash of your real password later
    initialPassword = "hunter1";
    isNormalUser = true;
    extraGroups = ["wheel", "sudo"];
  };
};
```

Add necessary kernel modules to boot
```
boot.initrd.kernelModules = [
    "usb_storage"
    "usbhid"
    "dm-crypt"
    "xts"
    "encrypted_keys"
    "ext4"
    "dm-snapshot"
  ];
```
