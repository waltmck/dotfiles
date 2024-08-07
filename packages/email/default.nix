{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  programs.geary.enable = true;

  home-manager.users.waltmck = {
    programs.mbsync.enable = true;
    programs.msmtp.enable = true;
    programs.astroid = {
      enable = true;
      extraConfig = {
        thread_view.open_html_part_external = false;
        poll.interval = 0;
      };
    };
    programs.aerc = {
      enable = true;
      extraConfig.general.unsafe-accounts-conf = true;
    };

    programs.neomutt.enable = true;

    programs.notmuch = {
      enable = true;
      hooks = {
        preNew = "mbsync --all";
      };
    };

    accounts.email = {
      accounts.fastmail = {
        address = "walt@mckelvie.org";
        imap.host = "imap.fastmail.com";
        mbsync = {
          enable = true;
          create = "maildir";
        };
        msmtp.enable = true;
        notmuch.enable = true;
        astroid.enable = true;
        aerc.enable = true;
        neomutt.enable = true;

        primary = true;
        realName = "Walter McKelvie";
        signature = {
          text = ''
          '';
          showSignature = "append";
        };
        passwordCommand = "op item get fastmail_walt-laptop --fields password";
        smtp = {
          host = "smtp.fastmail.com";
        };
        userName = "walt@mckelvie.org";
      };
    };
  };

  # Remember to enable "run in background" in the Geary user settings
  systemd.user.services.geary = {
    enable = true;
    description = "Geary Background Service";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];

    # Running through `zsh` so that it respects my user environment variables. This is not "best practice" but it is actually the easiest way to get this to work.
    script = ''
      ${pkgs.zsh}/bin/zsh -lc "${pkgs.gnome.geary}/bin/geary --gapplication-service"
    '';
  };

  # Dark mode for geary emails
  home-manager.users.waltmck.xdg.configFile."geary/user-style.css".text = ''
    @media (prefers-color-scheme: dark) {
      :root, *:not(a) {
        color: #eeeeec !important;
        background-color: #353535 !important;
      }
    }
  '';

  # Some tweaks to Geary settings
  home-manager.users.waltmck.dconf.settings."org/gnome/Geary" = {
    "ask-open-attachment" = true;
    "compose-as-html" = true;
    "formatting-toolbar-visible" = false;
    "images-trusted-domains" = ["*"];
    "run-in-background" = true; # This is important
  };

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      "Maildir"
      ".config/geary"
      ".local/share/geary"
      ".cache/geary"
      ".local/share/evolution" # to keep mail
    ];
  };
}
