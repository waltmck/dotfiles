{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  ...
}: {
  home-manager.users.waltmck = {
    programs.ssh = {
      enable = true;

      matchBlocks = {
        "walt-server" = {
          hostname = "waltmckelvie.com";
          user = "waltmck";
          forwardAgent = true;
        };
      };
    };
  };

  # Persist known_hosts
  environment.persistence."/nix/state".users.waltmck = {
    files = [".ssh/known_hosts"];
  };

  services.openssh = {
    enable = headless; # Disable ssh server (save battery, increase security) if not headless
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
