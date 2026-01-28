{ pkgs, ... }: {
  imports = [
    # 仅导入 Option 定义，所有模块的导入逻辑移交给 hosts/*.nix
    ./modules/options.nix 
  ];
  # 状态版本号 (所有机器共享)
  home.stateVersion = "24.05";
  # 启用 Home Manager 自身 (所有机器共享)
  programs.home-manager.enable = true;
}
