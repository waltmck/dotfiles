{pkgs, ...}: {
  services.aria2 = {
    enable = true;
    openPorts = false;
    # Will need to open default ports manually if I want to torrent using aria2

    rpcSecretFile =
      pkgs.writeText "aria2-secret.txt"
      ''
        secret
      '';
  };

  environment.persistence."/nix/state".directories = [
    "/var/lib/aria2"
  ];
}
