{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  ...
}: {
  services.headscale = {
    enable = true;
    address = "127.0.0.1"; #Only receive local connections (from nginx), in contrast to 0.0.0.0
    port = 8080;

    settings = {
      server_url = "https://headscale.waltmckelvie.com";

      dns_config = {
        magic_dns = true;
        base_domain = "headscale.waltmckelvie.com";
        domains = ["headscale.waltmckelvie.com"];
        nameservers = ["1.1.1.1" "9.9.9.9"];
      };

      listen_addr = "127.0.0.1:8080";
      metrics_listen_addr = "127.0.0.1:9090";

      derp = {
        server = {
          enabled = true;

          stun_listen_addr = "0.0.0.0:3478";
        };

        # TODO: specify derp server
        # paths = []
      };

      prefixes = {
        v6 = "fd7a:115c:a1e0::/48";
        v4 = "100.64.0.0/10";
      };
    };
  };

  # Allow UDP port for DERP
  networking.firewall.allowedUDPPorts = [3478];
}
