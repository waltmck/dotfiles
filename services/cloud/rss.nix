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

    baseUrl = "http://${hostname}/freshrss";

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
      /*
      # php files handling
      # this regex is mandatory because of the API
      locations."~ ^.+?\.php(/rss/.*)?$".extraConfig = ''
        fastcgi_pass unix:${config.services.phpfpm.pools.freshrss.socket};
        fastcgi_split_path_info ^(.+\.php)(/rss/.*)$;
        # By default, the variable PATH_INFO is not set under PHP-FPM
        include ${pkgs.nginx}/conf/fastcgi.conf;
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
      */

      /*
      locations."~ ^/freshrss/.+?\\.php(/.*)?$" = {
        root = "${pkgs.freshrss}/p";
        extraConfig = ''
          fastcgi_pass unix:${config.services.phpfpm.pools.freshrss.socket};
          fastcgi_split_path_info ^/freshrss(/.+\.php)(/.*)?$;
          set $path_info $fastcgi_path_info;
          fastcgi_param PATH_INFO $path_info;
          include ${pkgs.nginx}/conf/fastcgi_params;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          # include ${pkgs.nginx}/conf/fastcgi.conf;
        '';

        priority = 1100;
      };

      locations."~ ^/freshrss(/.*)?$" = {
        extraConfig = ''
          root ${pkgs.freshrss}/p;
          try_files $1 /freshrss$1/index.php$is_args$args;
        '';
        # root = "${pkgs.freshrss}/p";
        # tryFiles = "$1 /freshrss$1/index.php$is_args$args";
        priority = 1101;
      };
      */

      # Yet another try:

      locations."/freshrss" = {
        extraConfig = ''
          alias ${pkgs.freshrss}/p;
          index index.html index.htm index.php;
          try_files $uri $uri/ index.php;
          location ~ ^.+?\.php(/.*)?$ {
          include ${pkgs.nginx}/conf/fastcgi_params;
          	fastcgi_pass unix:${config.services.phpfpm.pools.freshrss.socket};
          	fastcgi_split_path_info ^(.+\.php)(/.*)$;
          	set $path_info $fastcgi_path_info;
          	fastcgi_param PATH_INFO $path_info;
          	fastcgi_param SCRIPT_FILENAME $request_filename;
          }
        '';
      };
    };
  };
}
