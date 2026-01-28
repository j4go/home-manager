{ config, pkgs, ... }:

{
  programs.bat = {
    enable = true;
    
    # 1. 基础配置 (主题与行为)
    config = {
      pager = "less -FR";   # 保持类似 less 的翻页体验
      theme = "Dracula";    # 设置你喜欢的主题
      style = "plain";      # 可选：简约风格
    };
    
    # 2. 额外插件 (强烈建议保留，太好用了)
    extraPackages = with pkgs.bat-extras; [ 
      batman    # 让 man 命令也带高亮
      batgrep   # 配合 ripgrep 显示高亮
    ];
  };

  # 3. 环境变量集成 (让 man 手册自动使用 bat)
  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
  };
}
