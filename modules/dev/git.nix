{
  config,
  lib,
  pkgs,
  ...
}: let
  proxy = config.myOptions.proxy;
in {
  # =================================================================
  # 1. Lazygit 配置
  # =================================================================
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        language = "en";
        timeFormat = "2006-01-02";
        shortTimeFormat = "15:04";
        showIcons = false;
        border = "rounded";
        nerdFontsVersion = "3";
      };
      git = {
        pagers = [
          {
            colorArg = "always";
            pager = "delta --dark --paging=never";
          }
        ];
      };
    };
  };

  # =================================================================
  # 2. Delta 配置
  # =================================================================
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = true;
      syntax-theme = "Dracula";
    };
  };

  # =================================================================
  # 3. Git 核心配置
  # =================================================================
  programs.git = {
    enable = true;
    # [严格保留] settings 格式原封不动
    settings = {
      user = {
        name = "j4go";
        email = "yianny@163.com";
      };
      push = {
        autoSetupRemote = true;
      };
      # 🚀 动态代理注入逻辑 (保留)
      # 仅当全局 proxy.enable 为 true 时，以下属性才会被写入 .config/git/config
      http = lib.mkIf proxy.enable {
        proxy = "http://${proxy.address}";
      };
      https = lib.mkIf proxy.enable {
        proxy = "http://${proxy.address}";
      };
    };
  };
}
