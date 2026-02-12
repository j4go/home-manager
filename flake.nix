# flake.nix
{
  description = "Multi-Host Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11"; # 建议与 home.stateVersion 保持一致
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snitch = {
      url = "github:karol-broda/snitch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    snitch,
    nixpkgs-unstable,
    ...
  } @ inputs: let
    # --- 辅助函数 ---
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;

    # [优化点 1]: 创建一个统一的 pkgs 构造器，避免重复
    pkgsFor = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          # 添加 unstable 源
          (final: prev: {
            unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          })
        ];
      };

    # [优化点 2]: 重构 mkHome，使其成为模块编排中心
    mkHome = hostName: system:
      home-manager.lib.homeManagerConfiguration {
        # 使用统一构造器
        pkgs = pkgsFor system;

        # 将 inputs 和 hostName 传递给所有模块
        extraSpecialArgs = {inherit inputs hostName;};

        # [核心优化]: 在此处定义完整的模块结构
        # 1. 加载通用基础配置 (所有主机共享)
        # 2. 加载主机专属配置 (定义变量和开关)
        # 3. 加载外部插件模块 (如 nixvim, snitch)
        modules = [
          # --- 1. 通用模块 ---
          ./home.nix # 包含别名、通用程序配置，并负责导入 basic_tools 和 shell

          # --- 2. 主机特定模块 ---
          ./hosts/${hostName} # 仅包含数据，不再有 imports

          # --- 3. 外部插件模块 ---
          nixvim.homeModules.nixvim
          snitch.homeManagerModules.default
          # 确保使用 flake 中的最新版 snitch 包
          {programs.snitch.package = snitch.packages.${system}.default;}
        ];
      };
  in {
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    homeConfigurations = {
      "w@mint" = mkHome "mint" "x86_64-linux";
      "w@alma" = mkHome "alma" "x86_64-linux";
      "w@fedora" = mkHome "fedora" "aarch64-linux";
      "w@rocky10" = mkHome "rocky10" "aarch64-linux";
    };
  };
}
