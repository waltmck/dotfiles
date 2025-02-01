{
  pkgs,
  lib,
  ...
}: {
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

  systemd.services.aria2.serviceConfig = {
    User = lib.mkForce "waltmck";
  };

  home-manager.users.waltmck.home.file.".varia/varia.conf" = let
    remote = "127.0.0.1";
    port = "6800";
    secret = "secret";
    remote_location = "/home/waltmck/Downloads";
  in {
    text = ''
      {"download_speed_limit_enabled": "0", "download_speed_limit": "0", "auth": "0", "auth_username": "", "auth_password": "", "download_directory": "/home/waltmck/Downloads", "download_simultaneous_amount": "5", "remote": "1", "remote_protocol": "http://", "remote_ip": "${remote}", "remote_port": "${port}", "remote_secret": "${secret}", "remote_location": "${remote_location}", "schedule_enabled": "0", "default_mode": "visible", "schedule_mode": "inclusive", "schedule": [], "remote_time": "0", "cookies_txt": "0", "check_for_updates_on_startup_enabled": "0"}
    '';
  };

  environment.persistence."/nix/state".directories = [
    "/var/lib/aria2"
  ];
}
