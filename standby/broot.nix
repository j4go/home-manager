{pkgs, ...}: {
  programs.broot = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      # 是否启用模态编辑（类似 Vim）
      modal = false;

      # 界面皮肤配置
      skin = {
        default = "ansi(238) / ansi(235)";
      };

      verbs = [
        {
          invocation = "p";
          execution = ":parent"; # 快速回到上级目录
        }
        {
          key = "enter";
          execution = "$EDITOR {file}";
          apply_to = "file"; # 仅对文件生效，文件夹依然保持“进入”动作
        }
        {
          invocation = "edit";
          shortcut = "e";
          execution = "$EDITOR {file}";
        }
      ];
    };
  };
}
