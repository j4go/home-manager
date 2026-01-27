# flake.nix
{
  description = "My Multi-Host Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: 
  let
    # 辅助函数：根据主机名生成配置
    mkHome = hostName: system: home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      # 🚀 关键点：将 vars 注入到所有模块中
      extraSpecialArgs = { 
        inherit hostName; 
        vars = import ./modules/lib/vars.nix { inherit hostName; };
      };
      modules = [
        ./home.nix
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
