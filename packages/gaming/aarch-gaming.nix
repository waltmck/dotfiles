{
  pkgs,
  patchedPkgs,
  pkgs86,
  ...
}: {
  environment.systemPackages = [
    patchedPkgs.slacky
    patchedPkgs.obsidian
    (patchedPkgs.vesktop.override {withSystemVencord = true;})
    pkgs.vencord
  ];

  environment.persistence."/nix/state".users.waltmck = {
    directories = [".config/slacky"];
  };
}
