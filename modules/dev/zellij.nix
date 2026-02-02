{pkgs, ...}: {
  programs.zellij = {
    enable = true;
    enableBashIntegration = false;

    settings = {
      # 1. 更改选用的主题名称
      theme = "everforest-dark";

      default_layout = "compact";
      mouse_mode = true;
      pane_frames = false;

      # 2. 定义深色主题色值 (Medium 对比度)
      everforest-dark = {
        fg = "#d3c6aa"; # 浅灰色文字
        bg = "#2d353b"; # 深绿色背景
        black = "#475258"; # 亮黑（灰色）
        red = "#e67e80";
        green = "#a7c080";
        yellow = "#dbbc7f";
        blue = "#7fbbb3";
        magenta = "#d699b6";
        cyan = "#83c092";
        white = "#d3c6aa";
        orange = "#e69875";
      };
    };
  };
}
