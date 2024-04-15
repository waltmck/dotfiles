{
  config,
  inputs,
  asztal,
  ...
}: {
  imports = [
    ../home-manager/nvim.nix
    # REFACTORED ../home-manager/ags.nix
    # REFACTORED ../home-manager/blackbox.nix
    # ../home-manager/browser.nix Need to fix firefox persistence
    ##### ../home-manager/bspwm.nix
    # REFACTORED ../home-manager/dconf.nix

    ##### ../home-manager/git.nix
    ##### ../home-manager/helix.nix
    # REFACTORED ../home-manager/hyprland.nix
    # REFACTORED ../home-manager/lf.nix

    # REFACTORED ../home-manager/packages.nix # <- wine problem
    # REFACTORED ../home-manager/sh.nix
    ../home-manager/starship.nix
    ../home-manager/stm.nix
    ##### ../home-manager/sway.nix
    # REFACTORED ../home-manager/theme.nix
    ../home-manager/tmux.nix
    # ../home-manager/wezterm.nix

    # REMOVED ../home-manager/distrobox.nix
    # REMOVED ../home-manager/neofetch.nix
    # REMOVED
  ];
}
