{ config, lib, ... }:
let 
  cfg = config.myOptions.shell.starship;
  settings = { 
    # 基础设置
    add_newline = false; # 不插入空行
    command_timeout = 2000;

    # 格式：只显示目录、Git 状态和提示符
    format = "$directory$git_branch$git_status$character";

    # 提示符：使用经典的箭头
    character = {
      success_symbol = "[➜](bold green)";
      error_symbol = "[✖](bold red)";
    };

    # 目录：简洁的绿色路径
    directory = {
      style = "bold cyan";
      truncate_to_repo = false;
      format = "[$path]($style) ";
    };

    # Git 分支：简洁的绿色
    git_branch = {
      style = "bold green";
      format = " on [$symbol$branch]($style) ";
    };

    # Git 状态：只在有改动时显示简洁的符号
    git_status = {
      style = "bold red";
      conflicted = "!"; ahead = "↑"; behind = "↓";
      diverged = "↕"; untracked = "?"; stashed = "$";
      modified = "M"; staged = "+"; renamed = "R"; deleted = "D";
      format = "([$all]($style)) ";
    };

    # 禁用所有语言模块和不必要的上下文
    package.disabled = true;
    time.disabled = true;
    username.disabled = true;
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
