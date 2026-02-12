{pkgs, ...}: {
  # 字体配置 (必须启用，否则 Nerdfonts 无法被终端识别)
  fonts.fontconfig.enable = true;

  # Tldr 配置
  programs.tealdeer = {
    enable = true;
    settings = {
      updates = {auto_update = false;};
      display = {
        compact = false;
        use_pager = false;
      };
    };
  };

  home.packages = with pkgs;
    [
      # --- 核心系统增强 ---
      jq # JSON 处理
      fx # JSON 查看
      yq-go # YAML/XML 处理
      ripgrep # 搜索 (rg)
      scooter # 查找替换
      duf # 磁盘查看
      dust # 目录分析
      gping # 图形化 Ping
      doggo # DNS 查询
      procs # 进程查看
      lnav # 日志查看
      ncdu # 目录占用
      rsync # 同步
      trash-cli # 安全删除 (alias rm)

      # --- 视觉与终端美化 ---
      fastfetch # 系统信息 (alias os/neo)
      macchina # 另一种系统信息
      figlet # 字符画 (alias print)
      toilet # 字符画增强
      chafa # 终端图片预览
      lolcat # 彩虹色输出

      # --- 网络与 Git ---
      httpie # HTTP 客户端
      xh # Httpie Rust版
      lazygit # Git TUI (alias lg)
      delta # Git Diff 美化
      gitnr # Gitignore 生成

      # --- 文件处理 ---
      imagemagick # 图片处理
      ffmpegthumbnailer # 视频缩略图
      poppler # PDF 处理

      # --- 压缩解压 ---
      zip
      unzip
      _7zz # 7zip (alias 7z)
      ouch # 智能解压

      # --- 开发环境 ---
      micromamba # Python 环境 (alias mamba)

      # --- 剪贴板 ---
      wl-clipboard # Wayland
      xclip # X11

      # --- 字体 ---
      # nerd-fonts.jetbrains-mono
      # maple-mono.NF-CN
    ]
    ++ [
      # --- Unstable 包 ---
      pkgs.unstable.hyperfine # 基准测试
      pkgs.unstable.bottom # 系统监控 (btm)
      # pkgs.unstable.yazi    # 如果需要最新版 Yazi
    ];
}
