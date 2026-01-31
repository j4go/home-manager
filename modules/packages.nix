{pkgs, ...}: {
  home.packages =
    # 1. 主体包：使用稳定的 pkgs
    (with pkgs; [
      yq-go
      jq # JSON 处理
      ripgrep # 极速搜索
      fd # 极速查找
      xclip # 剪贴板 (X11)
      wl-clipboard # 剪贴板 (Wayland)
      trash-cli # 安全删除
      hyperfine # 基准测试工具

      # 压缩解压工具套装
      zip
      unzip
      _7zz # 现代 7zip
      ouch

      duf # 磁盘空间查看
      dust # 目录占用分析
      gping # 图形化 Ping
      lazygit # Git 终端 UI
      delta # Git Diff 增强
      sd # 极速文本替换
      doggo # 现代 DNS 查询
      procs
    ])
    # 2. 增量包：如果是通过 overlay 注入，则直接使用 pkgs.unstable
    ++ [
      pkgs.unstable.fastfetch
    ];

  # tealdeer && 开启自动更新缓存
  programs.tealdeer = {
    enable = true;
    settings.updates.auto_update = true;
  };
}
