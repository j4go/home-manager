{pkgs, ...}: {
  programs.nh = {
    enable = true;
    # 自动清理设置：保留最近 3 天的生成版本，且最多保留 3 个
    clean = {
      enable = true;
      extraArgs = "--keep-since 3d --keep 3";
    };
    # 核心：定义 Flake 配置路径，nh 会自动识别
    # 建议使用绝对路径
    flake = "/home/w/.config/home-manager";
  };

  home.packages = with pkgs; [
    nvd # 用于展示版本差异对比
    nix-output-monitor # nh 内部调用的构建监控
  ];
}
