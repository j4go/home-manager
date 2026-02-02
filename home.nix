{
  lib,
  pkgs,
  ...
}:
with lib; # 引入 mkOption, mkEnableOption 等函数

  {
    # 自定义开关
    options.myOptions = {
      proxy = {
        enable = mkEnableOption "是否开启系统代理支持";
        address = mkOption {
          type = types.str;
          default = "127.0.0.1:10808";
          description = "代理服务器地址 (IP:Port)";
        };
      };
      shell = {
        zsh.enable = mkEnableOption "Zsh 模块";
        starship.enable = mkEnableOption "Starship 提示符";
      };
    };

    # 2. 原 home.nix 的内容：具体的配置实现
    config = {
      # 状态版本号 (所有机器共享)
      home.stateVersion = "24.05";

      # 启用 Home Manager (所有机器共享)
      programs.home-manager.enable = true;

      # 🚀 注意：如果在 hosts/*.nix 里已经定义了具体的 module 实现
      # 这里不需要变化。但如果你想在这里直接根据 option 启用功能，可以写：
      # programs.zsh.enable = config.myOptions.shell.zsh.enable;
    };
  }
