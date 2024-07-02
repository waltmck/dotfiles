{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [pkgs.newsflash];

  # Remember to enable "run in background" in the Geary user settings
  systemd.user.services.newsflash = {
    enable = true;
    description = "NewsFlash Background Service";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];

    # Running through `zsh` so that it respects my user environment variables. This is not "best practice" but it is actually the easiest way to get this to work.
    script = ''
      ${pkgs.zsh}/bin/zsh -lc "${pkgs.newsflash}/bin/io.gitlab.news_flash.NewsFlash --headless"
    '';
  };

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".local/share/news-flash" # I'm not sure why it uses both of these directories, probably a bug?
      ".local/share/news_flash"
      ".cache/news_flash"
      ".config/news-flash"
    ];
  };
}
