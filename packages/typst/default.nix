{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    typst
    typstyle
    tinymist
  ];

  # Custom typst packages
  home-manager.sharedModules = [
    {
      xdg.dataFile."typst/packages/waltmck".source = ./templates;
    }
  ];
}
