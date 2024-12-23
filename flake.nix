{
  description = "waltmck's personal system config";

  inputs = {
    # Core dependencies

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs.url = "github:serokell/deploy-rs";

    # Apple Silicon Stuff
    apple-silicon-support = {
      # url = "github:tpwrules/nixos-apple-silicon/main";

      # Minimal update plus Honeykrisp
      # url = "github:oliverbestmann/nixos-apple-silicon";

      # Opinionated + optimized update
      # url = "github:zzywysm/nixos-asahi";

      # My custom update
      url = "github:waltmck/nixos-asahi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-aarch64-widevine = {
      url = "github:epetousis/nixos-aarch64-widevine";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    # Misc dependencies
    nixvim.url = "github:nix-community/nixvim";

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
      url = "gitlab:waltmck/nur-expressions?dir=pkgs/firefox-addons";
      # url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Apps unavailable in nixpkgs
    zotero-nix = {
      url = "github:camillemndn/zotero-nix";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, ...} @ inputs: {
    nixosConfigurations = {
      "walt-laptop" = inputs.nixpkgs.lib.nixosSystem rec {
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
          pkgs86 = import inputs.nixpkgs {
            allowUnfree = true;
            system = "x86_64-linux";
          };

          # Look at gcc docs plus https://gpages.juszkiewicz.com.pl/arm-socs-table/arm-socs.html to find arch
          march = "armv8.6-a+fp16+fp16fml+aes+sha2+sha3+bf16+i8mm+nosve+nosve2+nomemtag+nosm4+nof32mm+nof64mm";
          native = false; # Build everything from source

          headless = false;
        };
      };

      # Initially, use `nix run github:numtide/nixos-anywhere -- --build-on-remote --flake .#walt-cloud root@cloud.waltmckelvie.com`
      # Note: when using nixos-anywhere to Hetzner, make sure to select the `linux-old` (kernel `6.3.1`) rather than
      # the `linux` (kernel `6.7.4`) rescue system--otherwise, there are problems with `kexec`.
      # Due to problems with impermanence, it will also be necessary to `nixos-anywhere` a basic version without impermanence. Then, impermanence can be added and permissions manually changed in `/nix/state` as we go.
      "walt-cloud" = inputs.nixpkgs.lib.nixosSystem rec {
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

          datasets = ["data"];
        };
      };

      "walt-desktop" = inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./hosts/desktop/configuration.nix
          # nixos-boot.nixosModules.default
          inputs.disko.nixosModules.disko
        ];
        specialArgs = {
          inherit inputs;
          inherit system;
          hostname = "walt-desktop";
          builder = true;

          native = false;
          headless = false;

          datasets = ["rpool/enc/state"];
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
        "walt-desktop" = {
          hostname = "walt-desktop";
          profiles.system = {
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."walt-desktop";
          };
        };
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
  };
}
