{pkgs, ...}: {
  programs.yazi = {
    enable = true;
    # 这会自动在 .bashrc 中注入一个 `y` 函数
    # 使用 `y` 命令启动 yazi，退出时会自动 cd 到当前目录
    # 尝试过设置为true 但y函数没有被识别 改成false 然后手动注入y函数
    enableBashIntegration = false;
    # 配置 yazi 的具体行为
    settings = {
      mgr = {
        show_hidden = true;
        sort_by = "mtime";
        sort_dir_first = true;
      };
    };
  };
}
