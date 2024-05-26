{pkgs, ...}: {
  # Make it a shared module so it works when you are root
  home-manager.sharedModules = [
    {
      programs.zsh.plugins = [
        {
          name = "zsh-powerlevel10k";
          src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
          file = "powerlevel10k.zsh-theme";
        }
      ];
    }
  ];
}
