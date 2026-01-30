{
  description = "Multi-Host Configuration";

  inputs = {
    # 1. 核心稳定化：锁定到最新的稳定分支
    # 注意：当前最新稳定版为 24.11，25.11 尚未发布。
    # 如果该分支不存在，请回退到 nixos-24.11 或使用 nixos-unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11"; 

    # 2. home-manager 依赖主 nixpkgs
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
    # --- 新增配置开始 ---
    # 定义支持的系统架构 (匹配您的 hosts 配置)
    systems = [ "x86_64-linux" "aarch64-linux" ];
    
    # 辅助函数：为所有架构生成配置
    forAllSystems = nixpkgs.lib.genAttrs systems;
    # --- 新增配置结束 ---

    mkHome = hostName: system: home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      # 将 system 显式传递给所有模块
      extraSpecialArgs = { inherit inputs hostName system; }; 
      modules = [
        ./home.nix                   # 基础通用配置
        nixvim.homeModules.nixvim    # 注入 nixvim 模块
        ./hosts/${hostName}          # 自动加载对应的 host 文件夹
      ];
    };
  in {
    # ✅ 启用格式化工具 (运行 nix fmt 时调用)
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

    homeConfigurations = {
      "rocky"   = mkHome "rocky"   "x86_64-linux";
      "mint"    = mkHome "mint"    "x86_64-linux";
      "rocky10" = mkHome "rocky10" "aarch64-linux"; 
      "fedora"  = mkHome "fedora"  "aarch64-linux";
    };
  };
}
