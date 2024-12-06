{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  hostname,
  ...
}: {
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "sysadmin@waltmckelvie.com";

    certs = {
      "cloud.waltmckelvie.com" = {};
    };
  };
  
  /*
  services.tailscaleAuth = {
    enable = true;
  };
*/

  services.nginx = {
    enable = true;

    # I'm pretty sure this actually does nothing, unfortunately
    /*
      tailscaleAuth = {
      enable = true;
      virtualHosts = [hostname];
      expectedTailnet = "waltmck.headscale.waltmckelvie.com";
    };
    */

    virtualHosts = {
      "cloud.waltmckelvie.com" = {
        enableACME = true;
        forceSSL = true;
      };
    };
  };

  # Persist SSL certificates
  environment.persistence."/nix/state" = {
    directories = [
      {
        directory = "/var/lib/acme";
        user = "acme";
        group = "acme";
        mode = "0755";
      }
    ];
  };
}
