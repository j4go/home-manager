{
  pkgs,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;
    # 建议开启整合，大佬通常追求全平台一致
    enableBashIntegration = false;

    settings = {
      # 1. 布局：信息第一行，提示符第二行
      # 这种两行式设计是业界公认最能兼顾“路径完整性”和“输入区固定”的方案
      format = lib.concatStrings [
        "$nix_shell"
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      # 2. 符号：Pure 风格精髓
      character = {
        success_symbol = "[❯](bold green) ";
        error_symbol = "[❯](bold red) ";
        vimcmd_symbol = "[❮](bold blue) ";
      };

      # 3. 目录：简洁明了，不使用截断（既然是双行显示，就该看清路径）
      directory = {
        style = "bold blue";
        format = "[$path]($style)[$read_only]($read_only_style) ";
        truncation_length = 0;
        truncate_to_repo = true; # 进入仓库后以仓库根目录为起点
      };

      # 4. Git：大佬级精简配置
      git_branch = {
        symbol = " ";
        style = "bold #ff5fd7"; # 经典的“猛男粉/暗紫色”分支标识
        format = "on [$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold red";
        format = "([\[$all_status$ahead_behind\]]($style) )";
        # 更加直观的状态符号
        conflicted = "=";
        ahead = "⇡";
        behind = "⇣";
        diverged = "⇕";
        untracked = "?";
        stashed = "$";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };

      # 5. 执行耗时：仅在超过 2 秒时出现，不干扰普通操作
      cmd_duration = {
        min_time = 2000;
        style = "italic yellow";
        format = "took [󱎫 $duration]($style) ";
      };

      # 6. Nix Shell
      nix_shell = {
        symbol = " ";
        style = "bold blue";
        format = "via [$symbol]($style) ";
      };

      # 7. 用户与主机 (仅在 SSH 时显示)
      username = {
        style_user = "white bold";
        style_root = "black bold";
        format = "[$user]($style) ";
        disabled = false;
        show_always = false;
      };

      hostname = {
        ssh_only = true;
        format = "on [$hostname](bold #ffaf00) ";
        disabled = false;
      };

      # 禁用繁杂模块
      package.disabled = true;
      python.disabled = true;
      cmake.disabled = true;
    };
  };
}
