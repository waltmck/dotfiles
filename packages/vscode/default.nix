{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  home-manager.users.waltmck.programs.vscode = {
    enable = true;

    userSettings = {
      "window.titleBarStyle" = "custom";
    };

    extensions = with pkgs.vscode-extensions; [
      kamadorueda.alejandra # Nix code formatter
      bbenoist.nix # Nix code prettifier
    ];
  };
}
