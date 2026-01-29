{ config, lib, pkgs, ... }:

let
  proxy = config.myOptions.proxy;
in {
  
  # =================================================================
  # 1. 新增：Lazygit 配置
  #    (这是独立的模块，不会干扰 programs.git)
  # =================================================================
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        showIcons = true;       # 显示图标
        border = "rounded";     # 圆角边框
      };
      git = {
        paging = {
          # 让 Lazygit 内部调用 Delta 进行渲染
          colorArg = "always";
          pager = "delta --dark --paging=never";
        };
      };
    };
  };

  # =================================================================
  # 2. 优化：Git 配置
  # =================================================================
  programs.git = {
    enable = true;

    # [新增] 启用 Delta 美化
    # 注意：这是 programs.git 的标准属性，通常与 settings 并列不会冲突
    # 如果报错，说明你的自定义 git 模块不支持 delta 属性，请移除此块
    delta = {
      enable = true;
      options = {
        navigate = true;      # 启用 n/N 跳转
        line-numbers = true;  # 显示行号
        side-by-side = true;  # 并排显示
        syntax-theme = "Dracula"; 
      };
    };

    # [严格保留] settings格式原封不动
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
