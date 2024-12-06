{
  pkgs,
  inputs,
  headless,
  ...
}: let
  texlive = pkgs.texlive.combined.scheme-full.withPackages (ps: with ps; [bbm]);
in {
  imports = [
    inputs.nixvim.nixosModules.nixvim
  ];

  environment.systemPackages =
    [
      pkgs.alejandra
      texlive
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
      normal = ["CaskaydiaCove Nerd Font"] # Will use the bundled Fira Code Nerd Font by default
      size = 13.0
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
    clipboard = {
      providers.wl-copy.enable = !headless;
      register = "unnamedplus";
    };

    keymaps =
      [
        {
          action = "<cmd>NvimTreeFindFileToggle<CR>";
          key = "<C-t>";
          options = {
            silent = true;
          };
        }
      ]
      ++ builtins.map (x: {
        action = "<cmd>wincmd ${x}<CR>";
        key = "<C-${x}>";
        options = {
          silent = true;
        };
      }) ["h" "j" "k" "l"];

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
      timeoutlen = 500;

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

      smoothscroll = true;
      wrap = true;

      expandtab = true;
      shiftwidth = 4;

      tabstop = 4;

      foldmethod = "expr";
      foldexpr = "nvim_treesitter#foldexpr()";
      foldenable = false;
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
    extraConfigLuaPre = let
      empty = "''";
    in ''
      vim.g.neovide_remember_window_size = false
      vim.g.neovide_scale_factor = 0.8
      vim.g.neovide_scroll_animation_length = 0.15

      local expr = {silent = true, expr = true, remap = false}
      vim.keymap.set(${empty}, 'j', "(v:count == 0 ? 'gj' : 'j')", expr)
      vim.keymap.set(${empty}, 'k', "(v:count == 0 ? 'gk' : 'k')", expr)

      vim.keymap.set("n", "<Space>", "<Nop>", { silent = true, remap = false })
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "
    '';

    plugins = {
      nvim-tree = {
        enable = true;
        openOnSetup = true;
        hijackCursor = true;
        actions.useSystemClipboard = true;

        renderer = {
          highlightGit = true;
          highlightModified = "all";
        };

        view.width = 25;
      };
      bufferline = {
        enable = true;
        /*
        TODO see example config
        settings = {
          options = {
            mode = "buffers";
          };
        };
        */
      };
      lualine.enable = true;
      gitsigns.enable = true;

      # trouble.enable = true;

      treesitter = {
        enable = true;
        nixvimInjections = true;
        settings = {
          indent = {
            enable = true;
          };
          folding = true;

          grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars;
        };
      };

      treesitter-context = {
        enable = true;
        settings = {
          mode = "topline";
          max_lines = 4;
        };
      };

      treesitter-refactor = {
        enable = true;
        highlightCurrentScope.enable = true;
      };

      # Language server protocol and none-ls for formatting
      lsp = {
        enable = true;
        servers = {
          nixd.enable = true; # Nix
          ts_ls.enable = true; # TypeScript
          texlab = {
            enable = true; # LaTeX

            # TODO these aren't working
            extraOptions = {
              build.onSave = true;
              chktex = {
                onEdit = true;
                onOpenAndSave = true;
              };

              latexindent = {
                local =
                  pkgs.writeText "latexindent.yaml"
                  ''
                    defaultIndent: "    "
                  '';

                modifyLineBreaks = true;
              };

              formatterLineLength = 0;
            };
          };

          lua_ls = {
            enable = true;
            settings.telemetry.enable = false;
          };

          ruff.enable = true;
        };

        keymaps = {
          lspBuf = {
            K = "hover";
            gD = "references";
            gd = "definition";
            gi = "implementation";
            gt = "type_definition";
          };
        };
      };
      lsp-format.enable = true;

      lspsaga.enable = true; # commands which use the lsp

      none-ls = {
        enable = true;
        enableLspFormat = true;

        sources.formatting = {
          alejandra = {
            enable = true;
            package = pkgs.alejandra;
          };
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
                ['<CR>'] = cmp.mapping.confirm({ select = false }),
              })
            '';
          };
          snippet = {
            expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          };
        };
      };

      which-key.enable = true;

      nvim-colorizer.enable = true;

      sleuth.enable = true;

      telescope = {
        enable = true;

        keymaps = {
          "<leader>fg" = "live_grep";
          "<leader>ff" = "find_files";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
        };

        extensions = {
          frecency.enable = true;
        };
      };

      # Git plugin
      fugitive.enable = true;

      web-devicons.enable = true;

      # Neorg is broken and additionally breaks Telescope, so disable
      /*
      neorg = {
        enable = true;
        modules = {
          "core.defaults" = {
            __empty = null;
          };
          "core.concealer" = {};
          "core.latex.renderer" = {};
          "core.completion" = {};
          "core.dirman" = {
            config = {
              workspaces = {
                notes = "~/Notes";
              };
            };
          };
        };

        logger.modes.info.level = "warn";
      };
      */

      /*
      copilot-lua = {
        enable = true;

        suggestion = {
          autoTrigger = true;
        };
      };
      */

      vimtex = {
        enable = true;
        texlivePackage = texlive;
        settings = {
          view_method = "zathura";
          fold_enable = 1;
          quickfix_mode = 0;
          complete_enabled = false; # Use vimtex for completion
        };
      };
    };

    colorschemes.vscode = {
      enable = true;
      settings = {};
    };
  };

  environment.persistence."/nix/state".users.waltmck = {
    directories = [".local/share/nvim"];
  };
}
