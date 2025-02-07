{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  hostname,
  nur,
  ...
}: {
  /*
  Disabled pending https://github.com/NixOS/nixpkgs/issues/332776
  services.flaresolverr = {
    enable = true;
  };
  */

  services.prowlarr = {
    enable = true;
  };

  services.sonarr = {
    enable = true;
    user = "data";
    group = "data";

    dataDir = "/data/config/sonarr";
  };

  services.radarr = {
    enable = true;
    user = "data";
    group = "data";

    dataDir = "/data/config/radarr";
  };

  services.lidarr = {
    enable = true;
    user = "data";
    group = "data";

    dataDir = "/data/config/lidarr";
  };

  services.readarr = {
    enable = true;
    user = "data";
    group = "data";

    dataDir = "/data/config/readarr";
  };

  services.bazarr = {
    enable = true;
    user = "data";
    group = "data";
  };

  systemd.services.speakarr = {
    description = "Speakarr";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      User = "data";
      Group = "data";
      ExecStart = "${pkgs.readarr}/bin/Readarr -nobrowser -data='/data/config/speakarr'";
      Restart = "on-failure";
    };
  };

  services.jellyseerr = {
    enable = true;
  };

  services.whisparr = {
    enable = true;
    user = "data";
    dataDir = "/data/config/whisparr";
  };

  services.nginx = let
    extraConfig = ''
      proxy_set_header Host $host;

      # Comment this line out to make *arr apps think that all traffic
      # is coming from localhost, disabling required authentication.
      # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_redirect off;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $http_connection;
    '';

    jellyseerrConfig = subdomain: ''
      set $app '${subdomain}';

      # Remove /${subdomain} path to pass to the app
      rewrite ^/${subdomain}/?(.*)$ /$1 break;

      # Redirect location headers
      proxy_redirect ^ /$app;
      proxy_redirect /setup /$app/setup;
      proxy_redirect /login /$app/login;

      # Sub filters to replace hardcoded paths
      proxy_set_header Accept-Encoding "";
      sub_filter_once off;
      sub_filter_types *;
      sub_filter '</head>' '<script language="javascript">(()=>{var t="$app";let e=history.pushState;history.pushState=function a(){arguments[2]&&!arguments[2].startsWith("/"+t)&&(arguments[2]="/"+t+arguments[2]);let s=e.apply(this,arguments);return window.dispatchEvent(new Event("pushstate")),s};let a=history.replaceState;history.replaceState=function e(){arguments[2]&&!arguments[2].startsWith("/"+t)&&(arguments[2]="/"+t+arguments[2]);let s=a.apply(this,arguments);return window.dispatchEvent(new Event("replacestate")),s},window.addEventListener("popstate",()=>{console.log("popstate")})})();</script></head>';
      sub_filter 'href="/"' 'href="/$app"';
      sub_filter 'href="/login"' 'href="/$app/login"';
      sub_filter 'href:"/"' 'href:"/$app"';
      sub_filter '\/_next' '\/$app\/_next';
      sub_filter '/_next' '/$app/_next';
      sub_filter '/api/v1' '/$app/api/v1';
      sub_filter '/login/plex/loading' '/$app/login/plex/loading';
      sub_filter '/images/' '/$app/images/';
      sub_filter '/android-' '/$app/android-';
      sub_filter '/apple-' '/$app/apple-';
      sub_filter '/favicon' '/$app/favicon';
      sub_filter '/logo_' '/$app/logo_';
      sub_filter '/site.webmanifest' '/$app/site.webmanifest';
    '';
  in {
    virtualHosts."${hostname}" = {
      # Note: if setting up from scratch, you must initially connect without the reverse proxy and set the URL Base and Application URL settings
      # Precisely: set URL Base to "/radarr" and Application URL to "${hostname}/radarr". This can be repeated for the rest of them.
      locations."^~ /radarr" = {
        proxyPass = "http://127.0.0.1:7878";

        inherit extraConfig;
      };
      locations."^~ /radarr/api" = {
        proxyPass = "http://127.0.0.1:7878";
        extraConfig = "auth_basic off;";
      };

      locations."^~ /sonarr" = {
        proxyPass = "http://127.0.0.1:8989";

        inherit extraConfig;
      };
      locations."^~ /sonarr/api" = {
        proxyPass = "http://127.0.0.1:8989";
        extraConfig = "auth_basic off;";
      };

      locations."^~ /lidarr" = {
        proxyPass = "http://127.0.0.1:8686";

        inherit extraConfig;
      };
      locations."^~ /lidarr/api" = {
        proxyPass = "http://127.0.0.1:8686";
        extraConfig = "auth_basic off;";
      };

      locations."^~ /prowlarr" = {
        proxyPass = "http://127.0.0.1:9696";

        inherit extraConfig;
      };
      locations."^~ /prowlarr/api" = {
        proxyPass = "http://127.0.0.1:9696";
        extraConfig = "auth_basic off;";
      };

      locations."^~ /readarr" = {
        proxyPass = "http://127.0.0.1:8787";

        inherit extraConfig;
      };
      locations."^~ /readarr/api" = {
        proxyPass = "http://127.0.0.1:8787";
        extraConfig = "auth_basic off;";
      };

      locations."^~ /speakarr" = {
        proxyPass = "http://127.0.0.1:8788";

        inherit extraConfig;
      };
      locations."^~ /speakarr/api" = {
        proxyPass = "http://127.0.0.1:8788";
        extraConfig = "auth_basic off;";
      };

      locations."^~ /jellyseerr" = {
        proxyPass = "http://127.0.0.1:5055";

        extraConfig = jellyseerrConfig "jellyseerr";
      };

      locations."^~ /bazarr" = {
        proxyPass = "http://127.0.0.1:6767";

        inherit extraConfig;
      };

      locations."^~ /whisparr" = {
        proxyPass = "http://127.0.0.1:6969";

        inherit extraConfig;
      };
      locations."^~ /whisparr/api" = {
        proxyPass = "http://127.0.0.1:6969";
        extraConfig = "auth_basic off;";
      };
    };

    virtualHosts."cloud.waltmckelvie.com".locations."^~ /request" = {
      proxyPass = "http://127.0.0.1:5055";

      extraConfig = jellyseerrConfig "request";
    };
  };
}
