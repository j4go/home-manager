{
  programs.starship = {
    enable = true;
    enableBashIntegration = false;

    settings = {
      # 1. 整体布局：双行显示
      # 第一行：目录、Git、耗时
      # 第二行：输入符号
      format = ''
        $nix_shell$directory$git_branch$git_status$cmd_duration
        $character'';

      # 2. 目录优化 (胶囊风格)
      directory = {
        style = "bg:blue fg:white bold";
        # 使用  和  包裹，形成圆角矩形
        format = "[](blue)[$path]($style)[](blue) ";
        truncation_length = 3;
        truncation_symbol = "…/";
      };

      # 3. Git 分支 (胶囊风格)
      git_branch = {
        symbol = "";
        style = "bg:peach fg:black bold";
        format = "[](peach)[$symbol $branch]($style)[](peach) ";
      };

      # 4. Git 状态
      git_status = {
        style = "bg:peach fg:black bold";
        format = "[](peach)[$all_status$ahead_behind]($style)[](peach) ";
      };

      # 5. Nix Shell 标识
      nix_shell = {
        symbol = "";
        style = "bg:blue fg:white bold";
        format = "[](blue)[$symbol]($style)[](blue) ";
      };

      # 6. 命令耗时
      cmd_duration = {
        min_time = 2000;
        style = "bg:yellow fg:black italic";
        format = "[](yellow)[󱎫 $duration]($style)[](yellow) ";
      };

      # 7. 输入符号
      character = {
        success_symbol = "[󱞩](bold green) ";
        error_symbol = "[󱞩](bold red) ";
      };

      # 调色盘
      palette = "my_palette";
      palettes.my_palette = {
        blue = "#81A1C1";
        peach = "#D08770";
        yellow = "#EBCB8B";
      };
    };
  };
}
