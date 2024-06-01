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
        "walt-cloud" = {
          hostname = "cloud.waltmckelvie.com";
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
  /*
  environment.persistence."/nix/state".files =
    if headless
    then [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ]
    else [];
  */

  services.openssh = {
    enable = headless; # Disable ssh server (save battery, increase security) if not headless
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
