{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  home-manager.sharedModules = let
    shellAliases = {
      "db" = "distrobox";
      "tree" = "eza --tree";
      "nv" = "nvim";
      "nvd" = "neovide";
      "nd" = "neovide";

      "ll" = "${pkgs.lsd}/bin/lsd -la";
      "l" = "${pkgs.lsd}/bin/lsd";

      "cat" = "${pkgs.bat}/bin/bat";
      "ping" = "${pkgs.gping}/bin/gping";
      "fetch" = "${pkgs.fastfetch}/bin/fastfetch";
      "sudo" = "sudo "; # This is so that other aliases will work with sudo

      ":q" = "exit";
      "q" = "exit";

      "open" = "xdg-open";

      "del" = "gio trash";

      "top" = "${pkgs.btop}/bin/btop";

      "fs" = "${pkgs.ncdu}/bin/ncdu -x /";

      "vimdiff" = "nvim -d";
      "diff" = "${pkgs.colordiff}/bin/colordiff";

      "y" = "${pkgs.kitty}/bin/kitten clipboard";
      "p" = "${pkgs.kitty}/bin/kitten clipboard -g";
      "latex-init" = "cp -n --no-preserve=all ${./template.tex} ./main.tex";
      "typst-init-pset" = "cp -n --no-preserve=all ${./template-pset.typ} ./main.typ";
    };
  in [
    {
      programs = {
        btop = {
          enable = true;

          settings.theme_background = false;
        };

        zsh = {
          inherit shellAliases;
          enable = true;
          enableCompletion = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          initExtra = ''
            SHELL=${pkgs.zsh}/bin/zsh
            zstyle ':completion:*' menu select
            bindkey "^[[1;5C" forward-word
            bindkey "^[[1;5D" backward-word
            unsetopt BEEP
            unsetopt HIST_SAVE_BY_COPY
            unsetopt HIST_FCNTL_LOCK
            setopt inc_append_history
            source ${pkgs.fzf}/share/fzf/key-bindings.zsh
          '';
        };

        bash = {
          inherit shellAliases;
          enable = true;
          initExtra = "SHELL=${pkgs.bash}";
        };

        nushell = {
          inherit shellAliases;
          enable = true;
          environmentVariables = {
            PROMPT_INDICATOR_VI_INSERT = "\"  \"";
            PROMPT_INDICATOR_VI_NORMAL = "\"∙ \"";
            PROMPT_COMMAND = ''""'';
            PROMPT_COMMAND_RIGHT = ''""'';
            NIXPKGS_ALLOW_UNFREE = "1";
            NIXPKGS_ALLOW_INSECURE = "1";
            SHELL = ''"${pkgs.nushell}/bin/nu"'';
            # TODO fix EDITOR = config.home.sessionVariables.EDITOR;
            # TODO fix VISUAL = config.home.sessionVariables.VISUAL;
          };
          extraConfig = let
            conf = builtins.toJSON {
              show_banner = false;
              edit_mode = "vi";
              shell_integration = true;

              ls.clickable_links = true;
              rm.always_trash = true;

              table = {
                mode = "compact"; # compact thin rounded
                index_mode = "always"; # alway never auto
                header_on_separator = false;
              };

              cursor_shape = {
                vi_insert = "line";
                vi_normal = "block";
              };

              menus = [
                {
                  name = "completion_menu";
                  only_buffer_difference = false;
                  marker = "? ";
                  type = {
                    layout = "columnar"; # list, description
                    columns = 4;
                    col_padding = 2;
                  };
                  style = {
                    text = "magenta";
                    selected_text = "blue_reverse";
                    description_text = "yellow";
                  };
                }
              ];
            };
            completion = name: ''
              source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/${name}/${name}-completions.nu
            '';
            completions = names:
              builtins.foldl'
              (prev: str: "${prev}\n${str}") ""
              (map (name: completion name) names);
          in ''
            $env.config = ${conf};
            ${completions ["cargo" "git" "nix" "npm"]}
          '';
        };
      };
    }
  ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [zsh nushell];

  security.sudo = {
    enable = true;

    # Otherwise we get sudo lecture every reboot
    extraConfig = ''
      Defaults lecture = never
    '';
  };

  # fzf config
  environment.sessionVariables = {
    FZF_ALT_C_COMMAND = "fd --type d --exclude .git --follow --hidden";
    FZF_DEFAULT_COMMAND = "fd --type f --exclude .git --follow --hidden";
    FZF_CTRL_T_COMMAND = "fd --type f --exclude .git --follow --hidden";

    ZVM_INIT_MODE = "sourcing"; # Fixes a problem with fzf keybindings
  };

  programs.fzf.keybindings = true;

  # Persist zsh history and completion cache
  environment.persistence."/nix/state".users.waltmck = {
    files = [
      ".zsh_history"
      # ".zcompdump" TODO figure out how to persist this
    ];
  };

  programs.direnv = {
    enable = true;
    silent = true;
  };

  environment.systemPackages = with pkgs; [
    devenv
  ];

  environment.variables = {
    # do not put in sessionVariables, breaks boot installation script
    SYSTEMD_COLORS = "1";
    ZFS_COLOR = "1";
  };
}
