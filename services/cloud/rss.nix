{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  hostname,
  ...
}: {
  services.freshrss = {
    enable = true;
    user = "data";

    dataDir = "/data/config/freshrss";
    virtualHost = null;

    baseUrl = "http://${hostname}/rss";

    authType = "none";
  };

  users.groups."freshrss" = {
    name = "freshrss";
  };
  users.users."freshrss" = {
    name = "freshrss";
    group = "freshrss";
    isSystemUser = true;

    createHome = false;
  };

  # TODO check out https://www.earth.li/~noodles/blog/2022/12/setting-up-freshrss-subdirectory.html

  # Set up a Nginx virtual host.
  services.nginx = {
    enable = true;
    virtualHosts."${hostname}" = {
      # php files handling
      # this regex is mandatory because of the API
      locations."~ ^.+?\.php(/rss/.*)?$".extraConfig = ''
        fastcgi_pass unix:${config.services.phpfpm.pools.freshrss.socket};
        fastcgi_split_path_info ^(.+\.php)(/rss/.*)$;
        # By default, the variable PATH_INFO is not set under PHP-FPM
        # But FreshRSS API greader.php need it. If you have a “Bad Request” error, double check this var!
        # NOTE: the separate $path_info variable is required. For more details, see:
        # https://trac.nginx.org/nginx/ticket/321
        set $path_info $fastcgi_path_info;
        fastcgi_param PATH_INFO $path_info;
        include ${pkgs.nginx}/conf/fastcgi_params;
        include ${pkgs.nginx}/conf/fastcgi.conf;
      '';

      locations."/rss/" = {
        alias = "${pkgs.freshrss}/p";
        tryFiles = "$uri $uri/ index.php";
        index = "index.php index.html index.htm";
      };
    };
  };
}
