# flake.nix (最终修复版)
{
  description = "Multi-Host Configuration";

  inputs = {
    # 1. 核心稳定化：锁定到最新的稳定分支 (nixos-25.11)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11"; 

    # 2. home-manager 依赖主 nixpkgs，并使用对应的 release 分支
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # 3. nixvim 依赖主 nixpkgs
    nixvim = {
      url = "github:nix-community/nixvim"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 4. 引入 unstable 源作为备用
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, home-manager, nixvim, ... }@inputs:
  let
    mkHome = hostName: system: home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      # 🚀 核心修复：将 system 显式传递给所有模块
      extraSpecialArgs = { inherit inputs hostName system; }; 
      modules = [
        ./home.nix                   # 基础通用配置
        nixvim.homeModules.nixvim    # 注入 nixvim 模块
        ./hosts/${hostName}          # 自动加载对应的 host 文件夹
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
