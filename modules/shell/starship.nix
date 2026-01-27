{ config, lib, ... }:
let 
  cfg = config.myOptions.shell.starship;
  settings = { 
    # 基础设置
    command_timeout = 2000;
    add_newline = false;
    line_break.disabled = true;

    # 格式：通过 format 统一控制所有模块的样式和顺序
    format = "$directory$git_branch$git_status$character";

    # 提示符：回归最简定义，移除所有样式和 format 属性
    character = {
      # 仅定义符号本身
      success_symbol = "$"; 
      error_symbol = "X";
      # 移除所有 style, format 属性，避免警告
    };
    
    # 目录：通过 format 属性来控制路径的显示样式，同时移除 style 属性
    directory = {
      style = "bold white"; # 样式保留在模块内，但 Starship 默认会应用
      truncate_to_repo = false;
      truncation_length = 2;
      format = "[$path]($style) "; # 路径用方括号包裹，并以空格结束
    };

    # Git 分支
    git_branch = {
      symbol = " on ";
      style = "bold white";
      format = "[$symbol$branch]($style)";
    };

    # Git 状态
    git_status = {
      style = "bold red";
      conflicted = "!"; ahead = "↑"; behind = "↓"; diverged = "↕";
      untracked = "?"; stashed = "S"; modified = "M"; staged = "+";
      renamed = "R"; deleted = "D";
      format = "([$all]($style)) ";
    };

    # 禁用所有默认语言模块，保持极简
    package.disabled = true;
    nodejs.disabled = true;
    python.disabled = true;
    golang.disabled = true;
    rust.disabled = true;
    
    # 禁用时间、用户名等不必要的上下文
    time.disabled = true;
    username.disabled = true;
    hostname.disabled = true;
  };
in {
  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = settings; 
    };
  };
}
