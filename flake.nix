{
  description = "waltmck's personal system config";

  inputs = {
    # Core dependencies

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence/master";

    # Deployment
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Apple Silicon Stuff
    apple-silicon-support = {
      url = "github:tpwrules/nixos-apple-silicon/main";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-aarch64-widevine = {
      url = "github:epetousis/nixos-aarch64-widevine";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    # Misc dependencies
    nix-colors.url = "github:kyesarri/nix-colors"; # colour themes

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "github:Aylur/ags";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    astal = {
      url = "github:Aylur/astal";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    matugen = {
      url = "github:InioX/matugen";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lf-icons = {
      url = "github:gokcehan/lf";
      flake = false;
    };

    # Firefox stuff
    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };

    betterfox = {
      url = "github:yokoffing/Betterfox";
      flake = false;
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zotero-nix = {
      url = "github:camillemndn/zotero-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-index-database,
    nixvim,
    home-manager,
    impermanence,
    apple-silicon-support,
    firefox-addons,
    betterfox,
    deploy-rs,
    disko,
    ...
  } @ inputs: {
    nixosConfigurations = {
      "walt-laptop" = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        modules = [
          ./hosts/laptop/default.nix
          # nixos-boot.nixosModules.default
        ];
        specialArgs = {
          inherit inputs;
          inherit system;
          hostname = "walt-laptop";
          builder = false;

          # Look at gcc docs plus https://gpages.juszkiewicz.com.pl/arm-socs-table/arm-socs.html to find arch
          march = "armv8.6-a+fp16+fp16fml+aes+sha2+sha3+bf16+i8mm+nosve+nosve2+nomemtag+nosm4+nof32mm+nof64mm";
          native = false;
          headless = false;
        };
      };

      # Initially, use `nix run github:numtide/nixos-anywhere -- --build-on-remote --flake .#walt-cloud root@cloud.waltmckelvie.com`
      # Note: when using nixos-anywhere to Hetzner, make sure to select the `linux-old` (kernel `6.3.1`) rather than
      # the `linux` (kernel `6.7.4`) rescue system--otherwise, there are problems with `kexec`.
      # Due to problems with impermanence, it will also be necessary to `nixos-anywhere` a basic version without impermanence. Then, impermanence can be added and permissions manually changed in `/nix/state` as we go.
      "walt-cloud" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./hosts/cloud/configuration.nix
          # nixos-boot.nixosModules.default
          inputs.disko.nixosModules.disko
        ];
        specialArgs = {
          inherit inputs;
          inherit system;
          hostname = "walt-cloud";
          builder = true;

          native = false;
          headless = true;
        };
      };

      "walt-phone" = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        modules = [
          ./hosts/phone/default.nix
        ];

        specialArgs = {
          inherit inputs;
          inherit system;
          hostname = "walt-phone";
          speedFactor = 1;
          builder = false;

          native = false;
          headless = true;
        };
      };
    };

    deploy = {
      sshUser = "root";
      user = "root";
      autoRollback = true;
      magicRollback = true;
      remoteBuild = true;
      nodes = {
        "walt-cloud" = {
          hostname = "cloud.waltmckelvie.com";
          profiles.system = {
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."walt-cloud";
          };
        };
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
  };
}
