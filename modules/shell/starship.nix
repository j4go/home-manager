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

      # 核心逻辑：移除全局末尾圆弧，由各模块自行收尾
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
      # Lavender: #b4befe (User/Host)
      # Sapphire: #74c7ec (Dir)
      # Mauve:    #cba6f7 (Git)
      # Peach:    #fab387 (Duration)
      # Surface0: #313244 (Alt Background)

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
        # 衔接：用 Lavender(#b4befe) 背景转到 Sapphire(#74c7ec)
        # 结尾：自带圆弧，如果后面没模块，它就是完美的结尾
        format = "[](fg:#b4befe bg:#74c7ec)[ $path ]($style)[](fg:#74c7ec)";
        truncation_length = 0;
        truncate_to_repo = false;
        truncation_symbol = "";
      };

      git_branch = {
        symbol = " ";
        style = "bg:#cba6f7 fg:#11111b bold";
        # 覆盖：用  覆盖 directory 的圆弧
        format = "[](fg:#74c7ec bg:#cba6f7)[ $symbol$branch]($style)";
      };

      git_status = {
        style = "bg:#cba6f7 fg:#11111b bold";
        # 结尾：自带圆弧
        format = "[$all_status$ahead_behind]($style)[](fg:#cba6f7)";
      };

      cmd_duration = {
        min_time = 500;
        style = "bg:#fab387 fg:#11111b bold";
        # 覆盖：用  覆盖 git 的圆弧
        format = "[](fg:#cba6f7 bg:#fab387)[  $duration ]($style)[](fg:#fab387)";
      };

      character = {
        success_symbol = "[❯](bold #a6e3a1)"; # Catppuccin Green
        error_symbol = "[❯](bold #f38ba8)"; # Catppuccin Red
      };
    };
  };
}
