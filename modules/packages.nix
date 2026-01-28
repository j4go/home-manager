{ pkgs, inputs, system, ... }:
let 
  # 核心：从 inputs 中获取 unstable 的包集
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
in {
  home.packages = 
    # 1. 主体包：使用稳定的 pkgs
    (with pkgs; [
      tealdeer
      yq-go
      jq            # JSON 处理
      ripgrep       # 极速搜索
      fd            # 极速查找
      xclip         # 剪贴板 (X11)
      wl-clipboard  # 剪贴板 (Wayland)
      trash-cli     # 安全删除
      hyperfine     # 基准测试工具

      # 压缩解压工具套装
      zip
      unzip
      _7zz          # 现代 7zip 

      duf           # 磁盘空间查看
      dust       # 目录占用分析
      gping         # 图形化 Ping
      lazygit       # Git 终端 UI
      delta         # Git Diff 增强
      sd            # 极速文本替换
      doggo         # 现代 DNS 查询
    ]) 
    
    # 2. 增量包：使用 unstablePkgs
    ++ [
      unstablePkgs.fastfetch
    ];

    # 为 tealdeer 开启自动更新缓存
    programs.tealdeer = {
      enable = true;
      settings.updates.auto_update = true;
    };
}
