{pkgs, ...}: {
  # Containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # VMs

  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;

  environment.systemPackages = with pkgs; [
    # Container management
    distrobox
    boxbuddy

    # VM management
    boxes
  ];
}
