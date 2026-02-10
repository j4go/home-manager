{
  pkgs,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      # 1. 彻底禁用 OS 模块（这个图标通常来自这里）
      os = {
        disabled = true;
      };

      # 2. 检查 hostname 模块
      # 确保 format 里面没有包含默认的图标变量
      hostname = {
        ssh_only = true; # 建议仅在 SSH 远程连接时显示
        format = "[$hostname]($style) "; # 去掉任何可能的图标前缀
        style = "bold green"; # 匹配你图中 mint 的颜色
      };

      # 3. 如果你使用了官方默认配置 (programs.starship.settings = { ... })
      # 确保全局 format 中没有意外插入 $os
      format = lib.concatStrings [
        "$username"
        "$hostname" # 刚才修改的部分
        "$directory"
        "$git_branch"
        "$git_status"
        "$character"
      ];

      directory = {
        truncation_length = 0; # 官方默认只保留最后 3 层路径
        truncate_to_repo = false; # 官方默认在 git 仓库中会缩短路径
        style = "bold cyan"; # 官方默认使用纯色文字，不带背景色块
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
}
