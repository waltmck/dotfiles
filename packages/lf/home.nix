{
  inputs,
  pkgs,
  headless,
  ...
}: {
  home.packages = with pkgs; [
    glib
    fzf
    bat
    unzip
    gnutar
    file
  ];

  programs.lf = {
    enable = true;

    commands = let
      trash = ''        ''${{
                set -f
                gio trash $fx
              }}'';
    in {
      trash = trash;
      delete = trash;

      open = ''
        ''${{
          readarray -t myfiles < <(echo "$fx")
          ${
          if headless
          then ''for f in "''${myfiles[@]}"; do nvim "$f" done''
          else ''for f in "''${myfiles[@]}"; do xdg-open "$f" & done''
        }
        }}
      '';

      fzf = ''        ''${{
                res="$(find . -maxdepth 1 | fzf --reverse --header='Jump to location')"
                if [ -n "$res" ]; then
                    if [ -d "$res" ]; then
                        cmd="cd"
                    else
                        cmd="select"
                    fi
                    res="$(printf '%s' "$res" | sed 's/\\/\\\\/g;s/"/\\"/g')"
                    lf -remote "send $id $cmd \"$res\""
                fi
              }}'';

      unzip = ''        ''${{
                set -f
                case $f in
                    *.tar.bz|*.tar.bz2|*.tbz|*.tbz2) tar xjvf $f;;
                    *.tar.gz|*.tgz) tar xzvf $f;;
                    *.tar.xz|*.txz) tar xJvf $f;;
                    *.zip) unzip $f;;
                    *.rar) unzip x $f;;
                    *.7z) 7z x $f;;
                esac
              }}'';

      zip = ''        ''${{
                set -f
                mkdir $1
                cp -r $fx $1
                zip -r $1.zip $1
                rm -rf $1
              }}'';

      pager = ''
        bat --paging=always "$f"
      '';

      on-select = ''        &{{
                lf -remote "send $id set statfmt \"$(eza -ld --color=always "$f")\""
              }}'';

      q = "quit";
    };

    keybindings = {
      a = "push %mkdir<space>";
      t = "push %touch<space>";
      r = "push :rename<space>";
      x = "trash";
      "." = "set hidden!";
      "<delete>" = "trash";
      "<enter>" = "open";
      V = "pager";
      f = "fzf";
    };

    settings = {
      scrolloff = 4;
      preview = true;
      drawbox = true;
      icons = true;
      cursorpreviewfmt = "";
    };
  };

  xdg.configFile."lf/icons".source = "${inputs.lf-icons}/etc/icons.example";
}
