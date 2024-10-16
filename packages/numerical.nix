{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = [
    (pkgs.julia.withPackages [
      "Optim"
      "Plots"
      "LanguageServer"
    ])

    pkgs.sage
  ];
}
