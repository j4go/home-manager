{
  programs.starship = {
    enable = true;
    enableBashIntegration = false;

    settings = {
      # 1. 整体布局：顶层色条 + 底层输入
      # 使用变量组合，确保模块之间没有物理空格
      format = ''
        [](blue)$nix_shell$directory[](fg:blue bg:peach)$git_branch$git_status[](fg:peach bg:yellow)$cmd_duration[](yellow)
        $character'';

      # 2. 目录：显示完整路径，不缩略
      directory = {
        style = "bg:blue fg:white bold";
        format = "[$path]($style)";
        truncation_length = 0; # 设置为 0 禁用缩略，显示完整路径
        fish_style_pwd_dir_length = 0;
      };

      # 3. Git 分支：紧贴目录
      git_branch = {
        symbol = "  ";
        style = "bg:peach fg:black bold";
        format = "[$symbol$branch]($style)";
      };

      # 4. Git 状态：紧贴分支
      git_status = {
        style = "bg:peach fg:black bold";
        format = "[$all_status$ahead_behind]($style)";
      };

      # 5. Nix Shell：最左侧标识
      nix_shell = {
        symbol = " ";
        style = "bg:blue fg:white bold";
        format = "[$symbol]($style)";
      };

      # 6. 命令耗时：色条末尾
      cmd_duration = {
        min_time = 2000;
        style = "bg:yellow fg:black bold";
        format = "[ 󱎫 $duration ]($style)";
      };

      # 7. 输入符号
      character = {
        success_symbol = "[╰─󱞩](bold green) ";
        error_symbol = "[╰─󱞩](bold red) ";
      };

      # 调色盘
      palette = "my_palette";
      palettes.my_palette = {
        blue = "#81A1C1"; # 莫兰迪蓝
        peach = "#D08770"; # 柔和橙
        yellow = "#EBCB8B"; # 柔和黄
      };
    };
  };
}
