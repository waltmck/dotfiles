{
  pkgs,
  patchedPkgs,
  pkgs86,
  ...
}: {
  environment.systemPackages = [
    patchedPkgs.slacky
    patchedPkgs.obsidian
  ];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [".config/slacky"];
  };
}
