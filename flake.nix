

{
  description = "waltmck's personal system config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";

    impermanence.url = "github:nix-community/impermanence/master";
  
    apple-silicon-support.url = "github:tpwrules/nixos-apple-silicon/main";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, impermanence, apple-silicon-support, ... } : {
    nixosConfigurations = {
      "walt-laptop" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}