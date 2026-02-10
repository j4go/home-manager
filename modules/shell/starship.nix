{
  pkgs,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    # 官方默认配置其实非常精简，大部分模块默认就是开启且配置好的
    settings = {
      # 官方默认的 format 顺序
      format = lib.concatStrings [
        "$all" # 包含所有默认模块
      ];

      # 如果你之前改乱了，这里可以显式重置关键模块到官方风格：

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
