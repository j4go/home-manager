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
      # 1. 布局：全模块胶囊化
      # [左半圆][内容][右半圆] 是关键逻辑
      format = lib.concatStrings [
        "$os"
        "$username"
        "$hostname"
        "[](fg:#a6e3a1)"
        "$directory"
        "[](fg:#a6e3a1) "
        "[](fg:#89b4fa)"
        "$git_branch"
        "$git_status"
        "[](fg:#89b4fa) "
        "[](fg:#fab387)"
        "$nix_shell"
        "[](fg:#fab387) "
        "$line_break"
        "$character"
      ];

      # 2. 右侧配置：将执行耗时独立出来，放在右侧并加上紫色胶囊
      right_format = "[](fg:#cba6f7)$cmd_duration[](fg:#cba6f7)";

      # 3. 目录配置：大佬级完整路径，不缩写，黑字绿底
      directory = {
        style = "bg:#a6e3a1 fg:#1e1e2e bold";
        format = "[$path]($style)";
        truncation_length = 0; # 禁用缩写
        truncate_to_repo = false;
        fish_style_pwd_dir_length = 0;
      };

      # 4. Git 模块：蓝底黑字
      git_branch = {
        symbol = " ";
        style = "bg:#89b4fa fg:#1e1e2e bold";
        format = "[ $symbol$branch ]($style)";
      };

      git_status = {
        style = "bg:#89b4fa fg:#1e1e2e bold";
        format = "[($all_status$ahead_behind)]($style)";
      };

      # 5. Nix Shell：橙底黑字
      nix_shell = {
        symbol = " ";
        style = "bg:#fab387 fg:#1e1e2e bold";
        format = "[ $symbol$state ]($style)";
      };

      # 6. 命令耗时：只有长任务才显示
      cmd_duration = {
        min_time = 500;
        style = "bg:#cba6f7 fg:#1e1e2e bold";
        format = "[  $duration ]($style)";
      };

      # 7. 用户名/主机名：淡蓝色调
      username = {
        show_always = true;
        style_user = "fg:#89dceb bold";
        format = "[$user]($style) ";
      };

      hostname = {
        ssh_only = true;
        style = "fg:#89dceb bold";
        format = "at [$hostname]($style) ";
      };

      # 8. 提示符：Pure 风格符号
      character = {
        success_symbol = "[❯](bold green) ";
        error_symbol = "[❯](bold red) ";
      };

      # 额外美化
      os = {
        disabled = false;
        format = "[$symbol ](fg:#89b4fa)";
        symbols.Almalinux = ""; # 自动识别你的 AlmaLinux
      };

      add_newline = true;
    };
  };
}
