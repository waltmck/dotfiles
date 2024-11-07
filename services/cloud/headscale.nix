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

      dns = {
        magic_dns = true;
        base_domain = "tailnet.waltmckelvie.com";
        domains = ["tailnet.waltmckelvie.com"];
        nameservers.global = ["1.1.1.1" "9.9.9.9"];
      };

      listen_addr = "127.0.0.1:8080";

      # Allow access using tailscale address`walt-cloud:9090/metrics`
      # Since port 9090 is not open in the firewall, this is private.
      metrics_listen_addr = "0.0.0.0:9090";

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

      # Use data partition for headscale state
      database.sqlite.path = "/data/config/headscale/db.sqlite";
      # db_path = "/data/config/headscale/db.sqlite";
      private_key_path = "/data/config/headscale/private.key";
      noise.private_key_path = "/data/config/headscale/noise_private.key";
    };
  };

  # Allow headscale to access its config directory
  systemd.services.headscale.serviceConfig.BindPaths = ["/data/config/headscale"];

  # Allow UDP port for DERP
  networking.firewall.allowedUDPPorts = [3478];
}
