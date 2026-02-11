{pkgs, ...}: {
  # 允许 Home Manager 管理字体配置文件
  # 这步如果不做，即使安装了包，终端也找不到字体
  fonts.fontconfig.enable = true;

  home.packages =
    # 主体包：using stable pkgs
    (with pkgs; [
      jq # JSON 处理的标准库
      fx # 交互式JSON查看与调试神器
      yq-go # JSON & YAML & XML
      fd # 极速查找
      ripgrep # 极速搜索
      scooter # 交互式查找替换
      duf # 磁盘空间查看
      dust # 目录占用分析
      gping # 图形化 Ping
      sd # 极速文本替换
      doggo # 现代 DNS 查询
      procs # 进程查看
      macchina # 类似fastfetch
      lnav # 替换less的日志查看工具
      ncdu # 查看目录大小
      rsync # 同步命令
      wl-clipboard # Wayland
      xclip # X11
      httpie # http cli client
      xh # httpie的rust重新实现
      lazygit # Git 终端 UI
      delta # Git Diff 增强
      gitnr # A CLI / TUI to generate .gitignore files using templates.
      imagemagick # 处理图片
      ffmpegthumbnailer # 处理视频
      poppler # 处理pdf 如pdf转图片预览等
      # --- 压缩解压工具套装 ---
      zip
      unzip
      _7zz # 现代 7zip
      ouch # 自动识别所有的后缀名 使用参数一致
      # --- 字体安装区域 ---
      # nerd-fonts.jetbrains-mono
      # maple-mono.NF-CN
    ])
    # 2. 增量包 using unstable pkgs
    ++ [
      pkgs.unstable.hyperfine # 基准测试工具
      pkgs.unstable.bottom # 类似btop htop
    ];

  # tealdeer -> tldr
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
        # 紧凑模式：去除多余空行
        compact = false;
        # 启用颜色输出
        use_pager = false;
      };
    };
  };
}
