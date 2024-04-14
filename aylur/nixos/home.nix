{
  config,
  inputs,
  asztal,
  ...
}: {
  imports = [
    ../home-manager/nvim.nix
    # REFACTORED ../home-manager/ags.nix
    ../home-manager/blackbox.nix
    # ../home-manager/browser.nix Need to fix firefox persistence
    ##### ../home-manager/bspwm.nix
    ../home-manager/dconf.nix
    ../home-manager/distrobox.nix
    ##### ../home-manager/git.nix
    ##### ../home-manager/helix.nix
    # REFACTORED ../home-manager/hyprland.nix
    ../home-manager/lf.nix
    ../home-manager/neofetch.nix
    ../home-manager/packages.nix # <- wine problem
    ../home-manager/sh.nix
    ../home-manager/starship.nix
    ../home-manager/stm.nix
    ##### ../home-manager/sway.nix
    # REFACTORED ../home-manager/theme.nix
    ../home-manager/tmux.nix
    # ../home-manager/wezterm.nix
  ];
}
