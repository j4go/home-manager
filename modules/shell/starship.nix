{
  pkgs,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = {
      # 核心布局：每一个模块都是独立的 [内容]
      # 这种“间断式胶囊”是目前 Hyprland 社区最硬核的审美，比连在一起的更高级
      format = lib.concatStrings [
        "$os"
        "$username"
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$line_break"
        "$character"
      ];

      # 右侧显示：将耗时放在最右边，紫色醒目胶囊
      right_format = "$cmd_duration";

      # -------------------------------------------------------------------------
      # 模块细节
      # -------------------------------------------------------------------------

      # OS 标识：修正 AlmaLinux 的报错
      os = {
        disabled = false;
        style = "fg:#89b4fa"; # 浅蓝色
        symbols = {
          AlmaLinux = " "; # 注意：A 和 L 都要大写
        };
      };

      username = {
        show_always = true;
        style_user = "fg:#89dceb bold"; # 青色文字
        format = "[$user]($style) [at](fg:#7f849c) ";
      };

      # 目录：绿色胶囊，黑字，显示完整路径
      directory = {
        style = "bg:#a6e3a1 fg:#11111b bold"; # 猫粮绿
        format = "[](fg:#a6e3a1)[$path]($style)[](fg:#a6e3a1) ";
        truncation_length = 0;
        fish_style_pwd_dir_length = 0;
      };

      # Git：蓝色胶囊
      git_branch = {
        symbol = " ";
        style = "bg:#89b4fa fg:#11111b bold";
        format = "[](fg:#89b4fa)[$symbol$branch]($style)[](fg:#89b4fa) ";
      };

      git_status = {
        style = "bg:#89b4fa fg:#11111b bold";
        format = "[[($all_status$ahead_behind)]($style)[](fg:#89b4fa) ]($style)";
      };

      # Nix Shell：橙色胶囊
      nix_shell = {
        symbol = " ";
        style = "bg:#fab387 fg:#11111b bold";
        format = "[](fg:#fab387)[$symbol$state]($style)[](fg:#fab387) ";
      };

      # 命令执行耗时：紫色胶囊
      cmd_duration = {
        min_time = 500;
        style = "bg:#cba6f7 fg:#11111b bold";
        format = "[](fg:#cba6f7)[ $duration]($style)[](fg:#cba6f7)";
      };

      # 提示符：大佬标配 Pure 风格
      character = {
        success_symbol = "[❯](bold green) ";
        error_symbol = "[❯](bold red) ";
      };

      # 全局美化
      add_newline = true;
    };
  };
}
