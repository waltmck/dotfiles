{
  description = "waltmck's personal system config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence/master";

    apple-silicon-support.url = "github:tpwrules/nixos-apple-silicon/main";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    nix-colors.url = "github:kyesarri/nix-colors"; # colour themes

    alejandra.url = "github:kamadorueda/alejandra/3.0.0"; # codeium nix
    ags.url = "github:Aylur/ags";
    astal.url = "github:Aylur/astal";
    matugen.url = "github:InioX/matugen";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    impermanence,
    hyprland,
    apple-silicon-support,
    alejandra,
    ags,
    ...
  } @ inputs: {
    nixosConfigurations = {
      "walt-laptop" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./hosts/laptop/default.nix
        ];
        specialArgs = {inherit inputs;};
      };
    };
  };
}
