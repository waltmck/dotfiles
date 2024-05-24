{
  pkgs,
  inputs,
  headless,
  ...
}: {
  imports = [
    inputs.nixvim.nixosModules.nixvim
  ];

  environment.systemPackages =
    [
      pkgs.alejandra
    ]
    ++ (
      if !headless
      then [pkgs.neovide]
      else []
    );

  environment.sessionVariables = {
    NEOVIDE_FORK = 1;
  };

  home-manager.users.waltmck.home.file.".config/neovide/config.toml".text = ''
    [font]
      normal = [] # Will use the bundled Fira Code Nerd Font by default
      size = 12.0
    fork = true
    frame = "none"
    idle = true
    maximized = false
    neovim-bin = "${pkgs.neovim}/bin/neovim" # in reality found dynamically on $PATH if unset
    no-multigrid = false
    tabs = false
    theme = "auto"
    vsync = true
  '';

  programs.nixvim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    # Sync clipboard with OS
    clipboard.providers.wl-copy.enable = !headless;

    opts = {
      ###################
      # Setting options #
      ###################
      # See `:help vim.opt`
      # NOTE: You can change these options as you wish!
      #  For more options, you can see `:help option-list`

      # Make line numbers default
      number = true;
      # You can also add relative line numbers, to help with jumping.
      # Experiment for yourself to see if you like it!
      relativenumber = true;

      # Enable mouse mode, can be useful for resizing splits for example!
      mouse = "a";

      # Don't show the mode, since it's already in the status line
      showmode = false;

      # Enable break indent
      breakindent = true;

      # Save undo history
      undofile = true;

      # Case-insensitive searching UNLESS \C or one or more capital letters in the search term
      ignorecase = true;
      smartcase = true;

      # Set highlight on search
      hlsearch = true;

      # Keep signcolumn on by default
      signcolumn = "yes";

      # Decrease update time
      updatetime = 250;

      # Decrease mapped sequence wait time
      # Displays which-key popup sooner
      timeoutlen = 300;

      # Configure how new splits should be opened
      splitright = true;
      splitbelow = true;

      # Sets how neovim will display certain whitespace characters in the editor.
      # See `:help 'list'`
      # and `:help 'listchars'`
      list = true;
      listchars = {
        tab = "» ";
        trail = "·";
        nbsp = "␣";
      };
      # Preview substitutions live, as you type!
      inccommand = "split";

      # Show which line your cursor is on
      cursorline = true;

      # Minimal number of screen lines to keep above and below the cursor.
      scrolloff = 10;
    };

    # To automatically open chadtree when opening a directory (i.e. `nvim .`)
    /*
      extraConfigLua = ''
      vim.api.nvim_create_autocmd("StdinReadPre", {
      	pattern = "*",
      	command = "let s:std_in=1"
      })
      vim.api.nvim_create_autocmd("VimEnter", {
      	pattern = "*",
      	command = "if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') | execute 'CHADopen' | execute 'cd '.argv()[0] | endif"
      })
    '';
    */

    # Disable neovide automatic fullscreen
    extraConfigLuaPre = ''
      vim.g.neovide_remember_window_size = false
      vim.g.neovide_scale_factor = 0.8
    '';

    plugins = {
      nvim-tree = {
        enable = true;
        openOnSetup = true;
        hijackCursor = true;
      };
      lualine.enable = true;
      gitsigns.enable = true;

      trouble.enable = true;

      treesitter = {
        enable = true;
        nixvimInjections = true;
        indent = true;
      };

      treesitter-context = {
        enable = true;
        settings.mode = "topline";
      };

      # Language server protocol and none-ls for formatting
      lsp = {
        enable = true;
        servers = {
          nixd.enable = true; # Nix
          tsserver.enable = true; # TypeScript

          lua-ls = {
            enable = true;
            settings.telemetry.enable = false;
          };
        };
      };
      lsp-format.enable = true;

      lspsaga.enable = true; # commands which use the lsp

      none-ls = {
        enable = true;
        enableLspFormat = true;

        sources.formatting.alejandra = {
          enable = true;
          package = pkgs.alejandra;
        };
      };

      # Completion which uses lsp
      cmp = {
        enable = true;
        autoEnableSources = true;

        settings = {
          sources = [
            {name = "nvim_lsp";}
            {name = "path";}
            {name = "buffer";}
            {name = "luasnip";}
          ];

          mapping = {
            __raw = ''
              cmp.mapping.preset.insert({
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
              })
            '';
          };
          snippet = {
            expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          };
        };
      };

      nvim-colorizer.enable = true;

      nix.enable = true;
    };

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        # terminal_colors = true;

        integrations = {
          cmp = true;
          gitsigns = true;
          treesitter = true;
        };
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
