{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  # Audio uses PipeWire/pipewire-pulse with WirePlumber

  # Just for pactl
  environment.systemPackages = [pkgs.pulseaudio];

  sound.enable = true;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber = {
      enable = true;

      # Disable unused virtual device
      configPackages = [
        (pkgs.writeTextDir "share/wireplumber/main.lua.d/51-alsa-disable.lua" ''
          rule = {
            matches = {
              {
                { "device.name", "equals", "alsa_card.platform-snd_aloop.0" },
              },
            },
            apply_properties = {
              ["device.disabled"] = true,
            },
          }

          table.insert(alsa_monitor.rules,rule)
        '')
      ];
    };
  };

  home-manager.users.waltmck.home.persistence."/nix/state/home/waltmck" = {
    files = [
      "/.local/state/wireplumber/restore-stream" # Persist volume
    ];
  };
}
