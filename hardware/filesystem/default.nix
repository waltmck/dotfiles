{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  # -- Filesystem and Boot Stuff --

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  boot.initrd.kernelModules = ["usb_storage" "usbhid" "dm-crypt" "xts" "encrypted_keys" "ext4" "dm-snapshot"];

  boot.initrd.luks.devices."encrypted" = {
    bypassWorkqueues = true;
    allowDiscards = true;
  };

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=8G" "mode=755"];
  };
}
