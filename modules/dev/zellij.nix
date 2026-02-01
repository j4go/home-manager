{pkgs, ...}: {
  programs.zellij = {
    enable = true;
    # 自动集成到 Bash 设置为true的话每次会自动进入zellij,打开一个新的会话
    # 这里要设置为false
    enableBashIntegration = false;

    # 核心设置
    settings = {
      # 选择主题
      theme = "everforest-light";
      # 默认布局
      default_layout = "compact";
      # 鼠标支持
      mouse_mode = true;
      # 简写模式：不显示底部提示栏 (熟练后开启)
      pane_frames = false;

      everforest-light = {
        fg = "#5c6a72";
        bg = "#f3f5d9";
        black = "#282e33";
        red = "#f85552";
        green = "#8da101";
        yellow = "#dfa000";
        blue = "#3a94c5";
        magenta = "#df69ba";
        cyan = "#35a77c";
        white = "#dfddc8";
        orange = "#f57d26";
      };
    };
  };
}
