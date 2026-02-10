{
  pkgs,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      os.disabled = true;

      # 1️⃣ 核心 format 布局
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      # --- 颜色定义 (Catppuccin Mocha) ---
      # Lavender: #b4befe (用户/主机)
      # Sapphire: #74c7ec (目录)
      # Mauve:    #cba6f7 (Git)
      # Peach:    #fab387 (耗时)

      username = {
        show_always = true;
        style_user = "bg:#b4befe fg:#11111b bold";
        format = "[](fg:#b4befe)[$user]($style)";
      };

      hostname = {
        ssh_only = true;
        style = "bg:#b4befe fg:#11111b bold";
        format = "[@$hostname]($style)";
      };

      directory = {
        style = "bg:#74c7ec fg:#11111b bold";
        # 衔接：从 Lavender(#b4befe) 背景切入 Sapphire(#74c7ec)
        # 末尾带圆弧：如果后面没模块，它就是完美的收尾
        format = "[](fg:#b4befe bg:#74c7ec)[ $path ]($style)[](fg:#74c7ec)";
        truncation_length = 0;
        truncate_to_repo = false; # 设为 false，确保进入 git 仓库也不缩减路径
        truncation_symbol = "";
      };

      git_branch = {
        symbol = " ";
        style = "bg:#cba6f7 fg:#11111b bold";
        # 技巧：这里的 [] 前景色设为上一级的 Sapphire(#74c7ec)，背景设为当前的 Mauve(#cba6f7)
        # 它会紧贴并视觉上“中和”掉前一个模块的圆弧
        format = "[](fg:#74c7ec bg:#cba6f7)[ $symbol$branch]($style)";
      };

      git_status = {
        style = "bg:#cba6f7 fg:#11111b bold";
        # 紧跟 branch，不需要前置衔接，但需要后缀圆弧收尾
        format = "[$all_status$ahead_behind]($style)[](fg:#cba6f7)";
      };

      cmd_duration = {
        min_time = 500;
        style = "bg:#fab387 fg:#11111b bold";
        # 衔接：从 Git 的 Mauve(#cba6f7) 切入 Peach(#fab387)
        format = "[](fg:#cba6f7 bg:#fab387)[  $duration ]($style)[](fg:#fab387)";
      };

      character = {
        # 使用 Catppuccin Green 和 Red
        success_symbol = "[❯](bold #a6e3a1)";
        error_symbol = "[❯](bold #f38ba8)";
      };

      # 2️⃣ 额外细节处理
      # 确保某些模块在没有数据时不显示多余的符号
      git_state.disabled = true;
    };
  };
}
