{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  hostname,
  ...
}: {
  environment.systemPackages = [pkgs.iperf];

  services.iperf3 = {
    enable = true;
    port = 5201;
    bind = "0.0.0.0";
  };

  services.nginx = {
    enable = true;

    virtualHosts."${hostname}" = {
      locations."/iperf3".proxyPass = "http://127.0.0.1:5201";
    };
  };

  # To test speed outside of tailscale VPN
  networking.firewall.allowedTCPPorts = [5201]; # if (hostname == "walt-cloud") then [5201] else [];
  networking.firewall.allowedUDPPorts = [5201];
}
