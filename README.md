# waltmck's dotfiles

Dotfiles for NixOS. Features:
* Impermanence, using `tmpfs` as root and home. The only persistent state between reboots is `/nix`.
* Full-disk encryption with LUKS
* Hyprland
* Aylur's Gnome Shell, with a tweaked version of [his incredible dotfiles](https://github.com/Aylur/dotfiles)
* Systemd integration with the shell and compositor launched as systemd services and apps launched as systemd scopes, allowing intelligent CPU and IO prioritization
* Various quality-of-life tweaks.

See installation instructions:
* [laptop](installation/laptop.md)
