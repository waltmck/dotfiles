{
  config,
  lib,
  pkgs,
  inputs,
  headless,
  ...
}: let
  ipv4 = "185.157.160.132/32";
  ipv6 = null;

  dnsconf = ''
    nameserver 46.227.67.134
    nameserver 192.165.9.158
    nameserver 2a07:a880:4601:10f0:cd45::1
    nameserver 2001:67c:750:1:cafe:cd45::1
  '';

  peer-port = 51413;

  /*
  The `vpn.conf` file has the following form, obtained from your VPN provider. Note the commented-out fields.

    [Interface]
    PrivateKey = <REDACTED>
    # Address = ${ipv4}, ${ipv6}
    # DNS = 46.227.67.134,192.165.9.158,2a07:a880:4601:10f0:cd45::1,2001:67c:750:1:cafe:cd45::1

    [Peer]
    PublicKey = <REDACTED>
    AllowedIPs = 0.0.0.0/0, ::/0
    Endpoint = <REDACTED>:<REDACTED>
  */
  vpnconf = "/nix/state/secrets/vpn.conf";
in {
  services.transmission = {
    enable = true;
    openRPCPort = true;

    user = "data";
    group = "data";

    settings = {
      # Torrent config

      bind-address-ipv4 = "0.0.0.0";
      bind-address-ipv6 =
        if ipv6 == null
        then "::1"
        else "::";
      port-forwarding-enabled = true;
      inherit peer-port;
      peer-port-random-enabled = false;

      encryption = 1;
      lpd-enabled = true;
      dht-enabled = true;
      pex-enabled = true;
      utp-enabled = true;

      # Config to get RPC to work
      rpc-bind-address = "127.0.0.1";
      rpc-port = 9091;
      rpc-url = "/transmission/";

      rpc-whitelist-enabled = true;
      rpc-host-whitelist-enabled = true;
      rpc-authentication-required = false;

      rpc-host-whitelist = "*";
      rpc-whitelist = "*";

      incomplete-dir = "/data/.incomplete";
      incomplete-dir-enabled = true;
      download-dir = "/data/downloads";
    };
  };

  systemd.services.transmission = {
    bindsTo = ["netns@wg.service"];
    requires = ["network-online.target"];
    after = ["wg.service"];
    wants = ["wg.service"];

    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/wg";
      PrivateTmp = true;
      PrivateNetwork = true;

      StandardOutput = "journal";
      StandardError = "journal";

      Environment = [
        # "TR_CURL_SSL_NO_VERIFY=1"
      ];

      BindPaths = ["/data/media"];
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
      ExecStart = with pkgs;
        writers.writeBash "wg-up" ''
          set -e
          ${iproute}/bin/ip link add wg0 type wireguard
          ${iproute}/bin/ip link set wg0 netns wg
          ${iproute}/bin/ip -n wg address add ${ipv4} dev wg0
          ${
            if ipv6 == null
            then ""
            else "${iproute}/bin/ip -n wg -6 address add ${ipv6} dev wg0"
          }
          ${iproute}/bin/ip netns exec wg \
            ${wireguard-tools}/bin/wg setconf wg0 ${vpnconf}
          ${iproute}/bin/ip -n wg link set lo up
          ${iproute}/bin/ip -n wg link set wg0 up
          ${iproute}/bin/ip -n wg route add default dev wg0
          ${
            if ipv6 == null
            then ""
            else "${iproute}/bin/ip -n wg -6 route add default dev wg0"
          }
        '';
      ExecStop = with pkgs;
        writers.writeBash "wg-down" ''
          ${iproute}/bin/ip -n wg route del default dev wg0
          ${
            if ipv6 == null
            then ""
            else "${iproute}/bin/ip -n wg -6 route del default dev wg0"
          }
          ${iproute}/bin/ip -n wg link del wg0
          ${iproute}/bin/ip -n wg link del lo
        '';

      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  # Fix DNS with the `wg` namespace, since it can't access tailscale DNS
  environment.etc."netns/wg/resolv.conf".text = dnsconf;

  # Socket to bridge RPC port (9091) to wg namespace
  systemd.sockets.transmission-rpc = {
    listenStreams = ["0.0.0.0:9091"];
    wantedBy = ["sockets.target"];
  };

  systemd.services.transmission-rpc = {
    requires = ["transmission.service" "transmission-rpc.socket"];
    after = ["transmission.service" "transmission-rpc.socket"];

    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 127.0.0.1:9091";
      PrivateTmp = true;
      PrivateNetwork = true;
      NetworkNamespacePath = "/var/run/netns/wg";

      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  environment.persistence."/nix/state".directories = [
    {
      directory = "/var/lib/transmission";
      user = "data";
      group = "transmission";
    }
  ];

  # Open wireguard port
  networking.firewall.allowedUDPPorts = [57974];
}
