{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  ...
}: {
  services.transmission = {
    enable = true;
    openRPCPort = true;

    user = "data";

    settings = {
      rpc-bind-address = "127.0.0.1";
      rpc-port = 9091;

      # rpc-whitelist = "127.0.0.1"; # Whitelist traffic coming from tailscale

      incomplete-dir = "/data/.incomplete";
      download-dir = "/data/downloads";
    };
  };

  systemd.services.transmission = {
    bindsTo = ["netns@wg.service"];
    requires = ["network-online.target"];
    after = ["wg.service"];
    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/wg";
    };
  };

  # --- VPN Configuration ---

  # Setup wireguard interface and namespace for transmission
  systemd.services."netns@" = {
    description = "%I network namespace";
    before = ["network.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute}/bin/ip netns add %I";
      ExecStop = "${pkgs.iproute}/bin/ip netns del %I";
    };
  };

  systemd.services.wg = {
    description = "wg network interface";
    bindsTo = ["netns@wg.service"];
    requires = ["network-online.target"];
    after = ["netns@wg.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = with pkgs; let
        ipv4 = "172.19.93.63/32"; # ipv4 VPN addr/cidr
        ipv6 = "fd00:0000:1337:cafe:1111:1111:9ac3:88de/128"; # ipv6 VPN addr/cidr
      in
        writers.writeBash "wg-up" ''
          set -e
          ${iproute}/bin/ip link add wg0 type wireguard
          ${iproute}/bin/ip link set wg0 netns wg
          ${iproute}/bin/ip -n wg address add ${ipv4} dev wg0
          ${iproute}/bin/ip -n wg -6 address add ${ipv6} dev wg0
          ${iproute}/bin/ip netns exec wg \
            ${wireguard-tools}/bin/wg setconf wg0 /nix/state/secrets/vpn.conf
          ${iproute}/bin/ip -n wg link set wg0 up
          ${iproute}/bin/ip -n wg route add default dev wg0
          ${iproute}/bin/ip -n wg -6 route add default dev wg0
        '';
      ExecStop = with pkgs;
        writers.writeBash "wg-down" ''
          ${iproute}/bin/ip -n wg route del default dev wg0
          ${iproute}/bin/ip -n wg -6 route del default dev wg0
          ${iproute}/bin/ip -n wg link del wg0
        '';

      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  # Socket to bridge RPC port (9091) to wg namespace
  systemd.sockets.transmission-rpc = {
    listenStreams = ["0.0.0.0:9091"];
    wantedBy = ["sockets.target"];
  };

  systemd.services.transmission-rpc = {
    requires = ["transmission.service" "transmission-rpc.socket"];
    after = ["transmission.service" "transmission-rpc.socket"];

    unitConfig.JoinsNamespaceOf = "transmission.service";

    serviceConfig = {
      type = "notify";
      ExecStart = "/usr/lib/systemd/systemd-socket-proxyd 127.0.0.1:9091";
      PrivateTmp = "yes";
      PrivateNetwork = "yes";
    };
  };

  networking.firewall.allowedUDPPorts = [57974]; # Open port for wireguard
}
