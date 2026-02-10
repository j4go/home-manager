{
  programs.starship = {
    enable = true;
    enableBashIntegration = false;

    settings = {
      # 1. 布局：第一行信息条，第二行仅符号
      format = "$nix_shell$directory$git_branch$git_status$cmd_duration\n$character";

      # 2. 目录：使用加粗蓝色，不带背景色（更耐看，不挤压）
      directory = {
        style = "bold blue";
        format = "[$path]($style) ";
        truncation_length = 4;
      };

      # 3. Git：使用简洁的斜杠分隔
      git_branch = {
        symbol = " ";
        style = "bold peach";
        format = "on [$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold red";
        format = "([\[$all_status$ahead_behind\]]($style) )";
      };

      # 4. 命令耗时：放在行尾显示
      cmd_duration = {
        min_time = 2000;
        style = "italic yellow";
        format = "took [󱎫 $duration]($style) ";
      };

      # 5. 符号：业界标准 "❯" (Pure Prompt 风格)
      character = {
        success_symbol = "[❯](bold green) ";
        error_symbol = "[❯](bold red) ";
        vimcmd_symbol = "[❮](bold green) ";
      };

      # 6. Nix Shell (Nix用户专属)
      nix_shell = {
        symbol = " ";
        style = "bold blue";
        format = "[$symbol]($style) ";
      };

      # 颜色定义
      palette = "my_palette";
      palettes.my_palette = {
        blue = "#81A1C1";
        peach = "#D08770";
        yellow = "#EBCB8B";
      };
    };
  };
}
