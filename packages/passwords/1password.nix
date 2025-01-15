{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    "${inputs.home-manager}/nixos"
  ];

  programs._1password = {
    package = pkgs._1password-cli;
    enable = true;
  };
  programs._1password-gui = {
    package = pkgs._1password-gui;
    enable = true;
    polkitPolicyOwners = ["waltmck"];
  };

  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      firefox
    '';
    mode = "0755";
  };

  # Start 1Password in the background so that ssh works immediately
  # systemd.user.services._1password = {
  #   enable = true;
  #   description = "_1Password";
  #   serviceConfig.PassEnvironment = "DISPLAY";

  #   script = "${pkgs._1password}/bin/1password --silent"

  #   wantedBy = ["multi-user.target"]; # starts after login
  # };

  systemd.user.services._1Password = {
    description = "_1Password";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];

    serviceConfig = {
      Environment = [
        "GDK_SCALE=${config.services.scaling.factor}"
      ];
      PassEnvironment = [
        "BROWSER"
        "XDG_CONFIG_DIRS"
        "XDG_BACKEND"
        "XCURSOR_SIZE"
        "XDG_SESSION_TYPE"
        "XDG_CURRENT_DESKTOP"
      ];
    };

    script = ''
      ${pkgs._1password-gui.override {polkitPolicyOwners = ["waltmck"];}}/bin/1password --silent
    '';
  };

  environment.sessionVariables = {
    SSH_AUTH_SOCK = "/home/waltmck/.1password/agent.sock";
  };

  /*
  home-manager.users.waltmck = {
    # Make ssh use 1password ssh-agent
    home.sessionVariables = {
      SSH_AUTH_SOCK = "/home/waltmck/.1password/agent.sock";
    };
  };
  */

  # Persist secret state
  environment.persistence."/nix/state".users.waltmck = {
    directories = [".config/1Password"];
  };
}
