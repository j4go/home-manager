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
          invocation = "edit";
          shortcut = "e";
          execution = "${pkgs.neovim}/bin/nvim {file}";
        }
      ];
    };
  };
}
