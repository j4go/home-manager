{ config, lib, ... }:
let 
  cfg = config.myOptions.shell.starship;
  # 🚀 极简主义 Starship 配置
  settings = { 
    # 基础设置
    command_timeout = 2000;
    add_newline = false;
    line_break.disabled = true;

    # 格式：只显示当前目录、Git 状态和提示符
    format = "$directory$git_branch$git_status$character";

    # 提示符：简单、干净的 $ 符号
    character = {
      success_symbol = "[ $ ](bold white)";
      error_symbol = "[ $ ](bold red)";
      # 仅在非根用户时显示
      vicmd_symbol = "[V](bold green)";
    };

    # 目录：只显示目录名，不显示颜色
    directory = {
      style = "bold white";
      truncate_to_repo = false;
      truncation_length = 2;
      format = "[$path]($style) "; # 确保路径后有一个空格
    };

    # Git 分支：纯文本，只在非主分支时显示
    git_branch = {
      symbol = " on ";
      style = "bold white";
      only_detached = false;
      truncation_length = 0;
      format = "[$symbol$branch]($style)"; # 示例: on main
    };

    # Git 状态：用简单的符号表示状态
    git_status = {
      style = "bold red";
      conflicted = "!";
      ahead = "↑";
      behind = "↓";
      diverged = "↕";
      untracked = "?";
      stashed = "S";
      modified = "M";
      staged = "+";
      renamed = "R";
      deleted = "D";
      format = "([$all]($style)) "; # 状态用括号包裹，并以空格结束
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
    # ... 其他所有未配置的模块默认都是禁用状态 ...
  };
in {
  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = settings; # 注入配置
    };
  };
}
