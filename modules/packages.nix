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

  # tealdeer：现代化的 tldr 客户端
  programs.tealdeer = {
    enable = true;
    settings = {
      updates = {
        # 禁用触发式更新：防止在查询时因网络请求导致终端卡顿
        # 手动更新命令：tldr -u
        auto_update = false;
        # 自动更新间隔（若开启）：建议设为 168 小时（一周）
        auto_update_interval_hours = 168;
      };
      display = {
        # 紧凑模式：去除多余空行，提升屏幕信息密度
        compact = true;
        # 启用颜色输出
        use_pager = false;
      };
    };
  };
}
