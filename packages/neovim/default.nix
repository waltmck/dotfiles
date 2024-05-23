{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixvim.nixosModules.nixvim
  ];

  environment.systemPackages = [
    pkgs.alejandra
  ];

  programs.nixvim = {
    enable = true;
    # plugins.lightline.enable = true;
    plugins.bufferline.enable = true;
    plugins.lualine.enable = true;
    plugins.gitsigns.enable = true;

    colorschemes.gruvbox = {
      enable = true;
      settings = {
        terminal_colors = true;
      };
    };
  };

  /*
  home-manager.users.waltmck.programs.neovim = {
    enable = true;
    programs.neovim = {
      enable = true;
      extraLuaConfig = ''
        ${builtins.readfile ./options.lua}
      '';

      plugins = with pkgs.vimPlugins; [
      ];
    };
  };
  */
}
