{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}: {
  environment.systemPackages = [
    pkgs.alejandra
  ];

  home-manager.users.waltmck.programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    userSettings = {
      "window.titleBarStyle" = "custom";
    };

    extensions = with pkgs.vscode-extensions; [
      kamadorueda.alejandra # Nix code formatter
      bbenoist.nix # Nix code prettifier
      ms-vscode.cpptools-extension-pack # C/C++ Tools
      github.copilot # GitHub Copilot
      ms-vscode-remote.remote-ssh # Remote SSH
    ];
  };

  # Persist cache state
  environment.persistence."/nix/state".users.waltmck = {
    directories = [".config/Code"];
  };
}
