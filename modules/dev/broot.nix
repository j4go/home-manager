{...}: {
  programs.broot = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      # 是否启用模态编辑（类似 Vim）
      modal = false;

      # 界面皮肤配置
      skin = {
        default = "gray 238 / gray 235";
      };

      verbs = [
        {
          invocation = "p";
          execution = ":parent"; # 快速回到上级目录
        }
        {
          invocation = "edit";
          shortcut = "e";
          # 确保Shell环境变量里有EDITOR，或者这里直接写 "${pkgs.neovim}/bin/nvim {file}"
          execution = "$EDITOR {file}";
        }
      ];
    };
  };
}
