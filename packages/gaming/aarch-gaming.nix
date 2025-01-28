{
  pkgs,
  patchedPkgs,
  pkgs86,
  ...
}: {
  environment.systemPackages = [
    patchedPkgs.slacky
  ];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [".config/slacky"];
  };
}
