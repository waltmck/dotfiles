{
  pkgs,
  config,
  ...
}: {
  # Containers
  /*
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  */

  virtualisation.docker = {
    enable = true;
  };

  # VMs

  programs.virt-manager.enable = true;
  virtualisation = {
    libvirtd.enable = true;
    # waydroid.enable = true; # Broken on asahi linux
  };

  environment.systemPackages = with pkgs; [
    # Container management
    boxbuddy

    # VM management
    boxes

    # Wayrdoird
    waydroid
  ];

  home-manager.sharedModules = [
    {
      imports = [./modules/distrobox.nix];

      programs.distrobox = {
        enable = true;

        boxes = let
          exec = "${pkgs.zsh}/bin/zsh";
          symlinks = [
            ".bashrc"
            ".zshrc"
            ".zsh"
            ".zshenv"
            ".ssh"
            ".config/nix"
            ".config/kitty"
            ".config/btop"
            ".config/git"
            ".config/newsboat"
            ".config/tmux"
            ".config/zathura"
            ".icons"
            ".local/share/neovide"

            ".local/share/vulkan"
          ];
          packages = with pkgs; [
            nix
            git
            _1password-cli
            newsboat
            tmux
            zathura
            neovide
          ];
        in {
          Gaming = {
            img = "docker.io/library/fedora:latest";
            inherit exec;
            symlinks =
              symlinks
              ++ [
                ".steam"
                ".local/share/Steam"
              ];

            init = ''
              # echo "test";
              dnf install -y "dnf-command(copr)";
              dnf copr enable -y @asahi/steam;
              dnf copr enable -y @asahi/mesa;
              # sudo dnf install -y steam;
            '';
          };
          Alpine = {
            inherit exec symlinks;
            img = "docker.io/library/alpine:latest";
          };
          Fedora = {
            inherit exec symlinks;
            packages = "nodejs npm poetry gcc mysql-devel python3-devel wl-clipboard";
            img = "registry.fedoraproject.org/fedora-toolbox:rawhide";
            nixPackages =
              packages
              ++ [
                (pkgs.writeShellScriptBin "pr" "poetry run $@")
                (pkgs.writeShellScriptBin "prpm" "poetry run python manage.py $@")
              ];
          };
          Arch = {
            inherit exec symlinks;
            img = "docker.io/library/archlinux:latest";
            packages = "base-devel wl-clipboard";
            nixPackages =
              packages
              ++ [
                (pkgs.writeShellScriptBin "yay" ''
                  if [[ ! -f /bin/yay ]]; then
                    tmpdir="$HOME/.yay-bin"
                    if [[ -d "$tmpdir" ]]; then sudo rm -r "$tmpdir"; fi
                    git clone https://aur.archlinux.org/yay-bin.git "$tmpdir"
                    cd "$tmpdir"
                    makepkg -si
                    sudo rm -r "$tmpdir"
                  fi
                  /bin/yay $@
                '')
              ];
          };
        };
      };
    }
  ];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".local/share/containers"
    ];
  };

  environment.persistence."/nix/state" = {
    directories = [
      "/var/lib/docker"
    ];
  };
}
