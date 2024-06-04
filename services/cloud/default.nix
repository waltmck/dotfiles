{...}: {
  imports = [
    ./nginx.nix
    ./headscale.nix
    ./transmission.nix
  ];

  users.groups."data" = {
    gid = 791;
    name = "data";
  };

  users.users."data" = {
    name = "data";
    group = "data";
    isSystemUser = true;
    uid = 791;

    home = "/data";
    createHome = true;
  };

  # Later: replace this with a mounted volume
  environment.persistence."/nix/state" = {
    directories = ["/data"];
  };
}
