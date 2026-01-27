{
  description = "World Class Multi-Host Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim.url = "github:nix-community/nixvim";
  };

  outputs = { self, nixpkgs, home-manager, nixvim, ... }@inputs:
  let
    # 核心重构：mkHome 现在只需要 hostName 和 system
    mkHome = hostName: system: home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit inputs hostName; };
      modules = [
        ./home.nix                   # 基础通用配置
        nixvim.homeModules.nixvim    # 注入 nixvim 模块
        ./hosts/${hostName}          # 🚀 自动加载对应的 host 文件夹
      ];
    };
  in {
    homeConfigurations = {
      # 只需要在这里指定架构和机器名
      "rocky"   = mkHome "rocky"   "x86_64-linux";
      "mint"    = mkHome "mint"    "x86_64-linux";
      "rocky10" = mkHome "rocky10" "aarch64-linux"; # ARM 架构
      "fedora"  = mkHome "fedora"  "aarch64-linux"; # ARM 架构
    };
  };
}
