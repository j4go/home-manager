{ pkgs, ... }: {
  imports = [
    # 🚀 仅导入 Option 定义，所有模块的导入逻辑移交给 hosts/*.nix
    ./modules/options.nix 
  ];
  
  # 状态版本号 (所有机器共享)
  home.stateVersion = "24.05";

  # 启用 Home Manager 自身 (所有机器共享)
  programs.home-manager.enable = true;

  # Nix 设置：注意，这只在 home-manager 有权限时生效
  # 推荐在 NixOS 或 system-wide 的 nix.conf 中设置，但在 home-manager 中保留亦可
  nix.package = pkgs.nix;
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
