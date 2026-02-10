{
  pkgs,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      # 1. 全局格式布局
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$conda"
        "$python"
        "$line_break"
        "$character"
      ];

      # 2. 基础模块配置
      os.disabled = true;

      hostname = {
        ssh_only = true;
        format = "[$hostname]($style) ";
        style = "bold green";
      };

      directory = {
        truncation_length = 0;
        truncate_to_repo = false;
        style = "bold cyan";
      };

      # 3. 环境显示模块
      conda = {
        symbol = "󱆠 ";
        format = "via [$symbol$environment]($style) ";
        style = "bold dim magenta";
      };

      python = {
        symbol = "🐍 ";
        format = "[$symbol($version )]($style)";
        style = "bold yellow";
        detect_files = ["pyproject.toml" "requirements.txt"];
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
}
