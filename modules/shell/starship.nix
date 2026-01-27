{ config, lib, ... }:
let 
  cfg = config.myOptions.shell.starship;
  settings = { 
    # 基础设置
    add_newline = false;
    command_timeout = 1000;

    # 格式：包含 Nix Shell 状态，并以 $ 符号结尾
    format = "$all$nix_shell$git_branch$git_status$directory$character";

    # 提示符
    character = {
      success_symbol = "[ $ ](bold green)";
      error_symbol = "[ ✗ ](bold red)";
    };

    # 目录
    directory = {
      style = "bold cyan";
      truncation_length = 2;
      format = "[$path]($style) ";
    };

    # Git 分支
    git_branch = {
      symbol = " "; # 使用 Nerdfont 符号
      style = "bold purple";
      format = "[$symbol$branch]($style) ";
    };

    # Git 状态
    git_status = {
      format = "[$all]($style) ";
      style = "bold red";
      up_to_date = "[✓](bold green)";
    };
    
    # Nix Shell 模块 (非常实用)
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
