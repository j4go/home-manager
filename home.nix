{lib, ...}:
with lib; {
  # 1. 自定义开关定义
  options.myOptions = {
    proxy = {
      enable = mkEnableOption "是否开启代理";
      address = mkOption {
        type = types.str;
        default = "127.0.0.1:10808";
        description = "代理服务器地址 (IP:Port)";
      };
    };
  };

  # 2. 具体的配置实现
  config = {
    # 状态版本号
    home.stateVersion = "24.05";
    # 启用 Home Manager
    programs.home-manager.enable = true;

    # 设置系统环境变量
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # 添加别名配置
    home.shellAliases = {
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      sedit = "sudo -E systemctl edit";
    };
  };
}
