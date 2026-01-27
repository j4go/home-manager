# flake.nix
{
  description = "My Multi-Host Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixvim, ... }@inputs:
  let
    mkHome = hostName: system: home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = {
        inherit hostName inputs; # 注入 inputs 方便在模块中引用
        vars = import ./modules/lib/vars.nix { inherit hostName; };
      };
      modules = [
        ./home.nix
        nixvim.homeModules.nixvim
        {
          home.username = "w";
          home.homeDirectory = "/home/w";
        }
      ];
    };
  in {
    homeConfigurations = {
      "rocky"   = mkHome "rocky"   "x86_64-linux";
      "mint"    = mkHome "mint"    "x86_64-linux";
      "rocky10" = mkHome "rocky10" "aarch64-linux";
      "fedora"  = mkHome "fedora"  "aarch64-linux";
    };
  };
}
