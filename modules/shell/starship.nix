{ config, lib, ... }:
let 
  cfg = config.myOptions.shell.starship;
  settings = { 
    # 基础设置
    add_newline = false;
    command_timeout = 1000;

    # 格式：通过 format 统一控制所有模块的样式和顺序
    # 提示符的样式将由 Starship 默认的 success_symbol/error_symbol 样式控制
    format = "$all$nix_shell$git_branch$git_status$directory$character";

    # 提示符：最稳定、最基础的定义，只保留符号
    character = {
      success_symbol = "➜"; 
      error_symbol = "✖"; 
      # 移除所有 format, error_format, style 属性，避免一切警告
    };

    # 目录
    directory = {
      style = "bold cyan";
      truncation_length = 2;
      format = "[$path]($style) ";
    };

    # Git 分支
    git_branch = {
      symbol = " "; 
      style = "bold purple";
      format = "[$symbol$branch]($style) ";
    };

    # Git 状态
    git_status = {
      format = "[$all]($style) ";
      style = "bold red";
      up_to_date = "[✓](bold green)";
    };
    
    # Nix Shell 模块
    nix_shell = {
      symbol = "❄️ ";
      style = "bold blue";
      format = "[$symbol(nix-shell)]($style) ";
    };

    # 禁用其他模块
    package.disabled = true;
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
