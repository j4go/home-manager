{
  programs.starship = {
    enable = true;
    enableBashIntegration = false; # 保持我们之前的策略：手动在 bash.nix 初始化

    settings = {
      # 1. 整体布局：双行显示
      # 第一行显示：Nix环境、目录、Git状态、命令耗时
      # 第二行显示：输入符号
      format = ''
        [](bold blue)$nix_shell$directory$git_branch$git_status$cmd_duration
        $character'';

      # 2. 目录优化
      directory = {
        style = "bg:blue fg:white bold";
        format = "[ $path ]($style)";
        truncation_length = 3; # 超过3层目录自动缩进
        truncation_symbol = "…/";
      };

      # 3. Git 状态优化 (更轻量)
      git_branch = {
        symbol = "";
        style = "bg:peach fg:black bold"; # 橙色背景
        format = "[[ $symbol $branch ]($style)]";
      };

      git_status = {
        style = "bg:peach fg:black";
        format = "[[($all_status$ahead_behind )]($style)]";
      };

      # 4. Nix Shell 标识 (Nix 用户灵魂)
      nix_shell = {
        symbol = "";
        style = "bg:blue fg:white bold";
        format = "[ $symbol ]($style)";
      };

      # 5. 命令耗时 (超过 2 秒显示)
      cmd_duration = {
        min_time = 2000;
        style = "bg:yellow fg:black italic";
        format = "[ 󱎫 $duration ]($style)";
      };

      # 6. 输入符号 (双行布局的第二行)
      character = {
        success_symbol = "[󱞩](bold green) "; # 成功时显示绿色箭头
        error_symbol = "[󱞩](bold red) "; # 失败时显示红色箭头
      };

      # 7. 调色盘与细节填充 (去掉多余的色块尾巴)
      palette = "my_palette";
      palettes.my_palette = {
        blue = "#81A1C1";
        peach = "#D08770";
        yellow = "#EBCB8B";
      };
    };
  };
}
