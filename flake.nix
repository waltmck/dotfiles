{
  description = "waltmck's personal system config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default-linux";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence/master";

    apple-silicon-support = {
      url = "github:tpwrules/nixos-apple-silicon/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprlang = {
      url = "github:hyprwm/hyprlang";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprlang";
      inputs.systems.follows = "systems";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    hyprlock = {
      url = "github:hyprwm/Hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprlang";
      inputs.systems.follows = "systems";
    };

    hypridle = {
      url = "github:hyprwm/hypridle";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprlang";
      inputs.systems.follows = "systems";
    };

    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprlang";
      inputs.systems.follows = "systems";
    };

    #hyprspace = {
    #  url = "github:KZDKM/Hyprspace";
    #  inputs.hyprland.follows = "hyprland";
    #};

    nix-colors.url = "github:kyesarri/nix-colors"; # colour themes

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0"; # codeium nix
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    astal = {
      url = "github:Aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    matugen = {
      url = "github:InioX/matugen";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lf-icons = {
      url = "github:gokcehan/lf";
      flake = false;
    };
    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixos-boot.url = "github:Melkor333/nixos-boot";
  };

  outputs = {
    self,
    nixpkgs,
    nix-index-database,
    home-manager,
    impermanence,
    hyprland,
    hyprlock,
    hypridle,
    hyprpaper,
    # hyprspace,
    apple-silicon-support,
    alejandra,
    ags,
    firefox-addons,
    # nixos-boot,
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
          arch = "armv8-a";
          hostname = "walt-laptop";
        };
      };
    };
  };
}
