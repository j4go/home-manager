{pkgs, ...}: {
  programs.yazi = {
    enable = true;
    # 这会自动在 .bashrc 中注入一个 `y` 函数
    # 使用 `y` 命令启动 yazi，退出时会自动 cd 到当前目录
    enableBashIntegration = false;
    # 可以在这里配置 yazi 的具体行为
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "modified";
        sort_dir_first = true;
      };
    };
  };
}
