{ config, lib, ... }:
{
  programs.htop = {
    enable = true;
    settings = {
      tree_view = 1;         # 树状视图
      show_program_path = 0; # 只显示进程名，不显示长路径
      highlight_base_name = 1;
      # 可以在这里配置 CPU 颜色等细节
    };
  };
}
