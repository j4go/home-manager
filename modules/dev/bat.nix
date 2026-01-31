{
  config,
  pkgs,
  ...
}: {
  programs.bat = {
    enable = true;
    # 1. 基础配置 (主题与行为)
    config = {
      pager = "less -FR"; # 保持类似 less 的翻页体验
      theme = "gruvbox-light"; # 设置你喜欢的主题
      # style = "numbers,changes"; # 可选：简约风格
      style = "header,grid,numbers";
    };
  };

  # 2. 额外插件 (强烈建议保留，太好用了)
  home.packages = with pkgs.bat-extras; [
    batman # 让 man 命令也带高亮
    batgrep # 配合 ripgrep 显示高亮
    batdiff # 提供 batdiff 命令
  ];
}
