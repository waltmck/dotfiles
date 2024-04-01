{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      "${inputs.home-manager}/nixos"
    ];

  programs._1password.enable = true;
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

  home-manager.users.waltmck = {
    # imports = [ "${inputs.impermanence}/home-manager.nix" ];

    programs.ssh = {
      extraConfig = ''
        Host *
            IdentityAgent ~/.1password/agent.sock
      '';
    };

    home.persistence."/nix/state/home/waltmck" = {
      directories = [ ".config/1Password" ];
    };
  };
}

