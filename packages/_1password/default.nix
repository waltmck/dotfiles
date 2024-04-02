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
    enable = true;
  };
  programs._1password-gui = {
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

    script = ''
      ${pkgs._1password-gui.override {polkitPolicyOwners = ["waltmck"];}}/bin/1password --silent 2>/home/waltmck/1password-logs
    '';
  };

  home-manager.users.waltmck = {
    # Make ssh use 1password ssh-agent
    programs.ssh = {
      extraConfig = ''
        Host *
            IdentityAgent ~/.1password/agent.sock
      '';
    };

    # Hyprland 1password quick access
    home.file.".config/hypr/per-app/_1password.conf" = {
      text = ''
        bind = $mainMod, T, exec, ${pkgs._1password-gui.override {polkitPolicyOwners = ["waltmck"];}}/bin/1password --quick-access
      '';
    };

    # Persist secret state
    home.persistence."/nix/state/home/waltmck" = {
      directories = [".config/1Password"];
    };
  };
}
