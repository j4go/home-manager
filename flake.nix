{
  description = "Multi-Host Configuration";

  inputs = {
    # 锁定到最新的稳定分支
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # home-manager 依赖主 nixpkgs
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixvim 依赖主 nixpkgs
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 引入 unstable 源作为备用
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    nixpkgs-unstable,
    ...
  } @ inputs: let
    # 定义支持的系统架构 (匹配您的 hosts 配置)
    systems = ["x86_64-linux" "aarch64-linux"];

    # 辅助函数：为所有架构生成配置
    forAllSystems = nixpkgs.lib.genAttrs systems;

    overlay-unstable = final: prev: {
      unstable = import nixpkgs-unstable {
        system = prev.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    };

    mkHome = hostName: system:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [overlay-unstable];
          config.allowUnfree = true;
        };

        # 将 hostName 显式传递给所有模块
        extraSpecialArgs = {inherit inputs hostName;};
        modules = [
          ./home.nix # 基础通用配置
          ./hosts/${hostName} # 加载对应的 host 文件夹
          nixvim.homeModules.nixvim # nixvim 模块
        ];
      };
  in {
    # 格式化工具 (运行 nix fmt 时调用)
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    homeConfigurations = {
      "mint" = mkHome "mint" "x86_64-linux";
      "alma" = mkHome "alma" "x86_64-linux";
      "fedora" = mkHome "fedora" "aarch64-linux";
      "rocky10" = mkHome "rocky10" "aarch64-linux";
    };
  };
}
