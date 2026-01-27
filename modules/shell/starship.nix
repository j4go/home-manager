{ config, lib, ... }:
let 
  cfg = config.myOptions.shell.starship;
  settings = { 
    # 基础设置
    command_timeout = 2000;
    add_newline = false;
    line_break.disabled = true;

    # 格式：只显示当前目录、Git 状态和提示符
    format = "$directory$git_branch$git_status$character";

    # 提示符：修复了空格错误，并使用 format 属性来确保简洁
    character = {
      # 修复了 format 语法，使用 $symbol 变量
      format = "[$symbol]($style) "; 
      success_symbol = "$"; # 仅保留符号本身
      error_symbol = "X";   # 仅保留符号本身
      style = "bold white";
      # 移除 vicmd_symbol 的格式化，使用默认的
    };

    # 目录：只显示目录名
    directory = {
      style = "bold white";
      truncate_to_repo = false;
      truncation_length = 2;
      format = "[$path]($style) ";
    };

    # Git 分支：移除 length=0 警告
    git_branch = {
      symbol = " on ";
      style = "bold white";
      # 移除 only_detached，避免警告
      format = "[$symbol$branch]($style)";
      # 移除 truncation_length = 0，避免警告
    };

    # Git 状态：用简单的符号表示状态
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
