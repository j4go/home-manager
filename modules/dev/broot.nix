#     __                     __
#    / /_  _________  ____  / /_
#   / __ \/ ___/ __ \/ __ \/ __/
#  / /_/ / /  / /_/ / /_/ / /_
# /_.___/_/   \____/\____/\__/
#
{
  config,
  pkgs,
  ...
}: {
  programs.broot = {
    enable = true;

    enableBashIntegration = true;

    settings = {
      modal = false; # 是否启用模态编辑（类似 Vim）

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
          # 💡 确保你的 Shell 环境变量里有 EDITOR，或者这里直接写 "${pkgs.neovim}/bin/nvim {file}"
          execution = "$EDITOR {file}";
        }
      ];
    };
  };
}
