{
  pkgs,
  patchedPkgs,
  pkgs86,
  ...
}: {
  environment.systemPackages = [
    patchedPkgs.muvm
    pkgs86.steam
  ];
}
