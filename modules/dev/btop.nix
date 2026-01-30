{
  config,
  pkgs,
  ...
}: {
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "catppuccin_mocha"; # 业界目前更推崇 Catppuccin，色彩对比度更科学
      theme_background = false;
      update_ms = 500;
      vim_keys = true; # 🧐 核心建议：保持与 Neovim 一致的操作逻辑
      graph_symbol = "braille"; # 使用点阵图，视觉细腻度更高
      proc_sorting = "cpu lazy"; # 智能排序，减少排序本身的 CPU 占用
      check_temp = true; # 确保开启温度监控
      cpu_sensor = "Auto";
      show_gpu = "on"; # 🔴 必须手动开启，尤其是在做 AI/Dev 开发时
    };
  };
}
