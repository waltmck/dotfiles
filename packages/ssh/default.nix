{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  home-manager.users.waltmck = {
    programs.ssh = {
      enable = true;

      extraConfig = lib.mkOrder 1 ''
        Host walt-server
            HostName waltmckelvie.com
            User waltmck
            ForwardAgent yes
      '';
    };

    # Persist known_hosts
    home.persistence."/nix/state/home/waltmck" = {
      files = [".ssh/known_hosts"];
    };
  };

  services.openssh = {
    enable = false; # Disable ssh server (save battery, increase security)
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
